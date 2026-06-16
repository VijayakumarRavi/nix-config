# Production PostgreSQL 18 with pgBackRest S3 backups, Let's Encrypt SSL,
# and automated disaster recovery.
#
# Prerequisites:
#   - sops-nix module must be imported (modules/nixos/default.nix handles this)
#   - Secrets must be defined in secrets.yaml (see walkthrough)
#   - DNS A/AAAA record for acmeDomain must point to this server
#   - S3 bucket must exist before first deployment
#
# Boot sequence:
#   1. NixOS activation decrypts sops secrets
#   2. ACME obtains/verifies Let's Encrypt certificate
#   3. pgbackrest-repo-validate verifies S3 connectivity
#   4. pgbackrest-auto-restore restores from backup if data dir is empty
#   5. postgresql.service starts (initdb if fresh, stanza-create + initial backup)
#   6. Backup timers activate
{
  config,
  pkgs,
  lib,
  hostname,
  variables,
  ...
}: let
  # ── Configuration ──────────────────────────────────────────────────────
  pgPackage = pkgs.postgresql_18;
  pgBackRest = pkgs.pgbackrest;
  stanzaName = hostname;
  pgDataDir = "/var/lib/postgresql/${pgPackage.psqlSchema}";
  acmeDomain = "db.vjlab.dev";
  acmeCertDir = "/var/lib/acme/${acmeDomain}";

  # ── Extensions ─────────────────────────────────────────────────────────
  pgExtensions = with pgPackage.pkgs; [
    timescaledb
    vectorchord
  ];

  # ── Derived paths ─────────────────────────────────────────────────────
  pgbackrestConfigPath = config.sops.templates."pgbackrest.conf".path;
  pgbackrestBin = "${pgBackRest}/bin/pgbackrest";
  pgbackrestBase = "${pgbackrestBin} --config=${pgbackrestConfigPath}";
  pgbackrestCmd = "${pgbackrestBase} --stanza=${stanzaName}";
  curl = "${pkgs.curl}/bin/curl";
  jq = "${pkgs.jq}/bin/jq";
  install = "${pkgs.coreutils}/bin/install";

  # ── Healthcheck URL helper (same pattern as restic backups) ────────────
  # Reads the URL from sops secret, pings /start before and / or /fail after
  hcSecretPath = config.sops.secrets.pg_backup_hc_url.path;

  # Reusable backup script generator
  mkBackupScript = {
    type,
    runExpire ? true,
  }: ''
    set -euo pipefail

    HC_URL=$(cat ${hcSecretPath} 2>/dev/null || echo "")

    if [ -n "$HC_URL" ]; then
      ${curl} -fsS -m 10 --retry 3 -o /dev/null "$HC_URL/start" || true
    fi

    echo "=== pgBackRest ${type} Backup ==="
    echo "Timestamp: $(date -Is)"

    if ${pgbackrestCmd} backup --type=${type}; then
      echo "${type} backup completed."
      ${lib.optionalString runExpire ''
      ${pgbackrestCmd} expire
      echo "Expired old backups per retention policy."
    ''}
      echo "=== Done ==="

      if [ -n "$HC_URL" ]; then
        ${curl} -fsS -m 10 --retry 3 -o /dev/null "$HC_URL" || true
      fi
    else
      echo "=== BACKUP FAILED ==="

      if [ -n "$HC_URL" ]; then
        ${curl} -fsS -m 10 --retry 3 -o /dev/null "$HC_URL/fail" || true
      fi
      exit 1
    fi
  '';
in {
  # ════════════════════════════════════════════════════════════════════════
  # §1  PostgreSQL Service
  # ════════════════════════════════════════════════════════════════════════
  services.postgresql = {
    enable = true;
    package = pgPackage;
    dataDir = pgDataDir;
    extensions = pgExtensions;

    settings = {
      # ── Connection ──
      listen_addresses = lib.mkForce "*";
      port = 24957;
      max_connections = 100;

      # ── Memory ──
      shared_buffers = "256MB";
      effective_cache_size = "768MB";
      work_mem = "4MB";
      maintenance_work_mem = "64MB";

      # ── WAL & Archiving ──
      wal_level = "replica";
      archive_mode = "on";
      archive_command = "${pgbackrestBin} --config=${pgbackrestConfigPath} --stanza=${stanzaName} archive-push %p";
      max_wal_senders = 5;

      # ── Extensions ──
      shared_preload_libraries = "timescaledb,vchord";

      # ── SSL (Let's Encrypt) ──
      ssl = true;
      ssl_cert_file = "${pgDataDir}/certs/fullchain.pem";
      ssl_key_file = "${pgDataDir}/certs/key.pem";

      # ── Authentication ──
      password_encryption = "scram-sha-256";

      # ── Logging ──
      log_connections = true;
      log_disconnections = true;
      log_line_prefix = "%m [%p] %q%u@%d ";
    };

    # Local: peer for postgres (pgBackRest + maintenance), SCRAM for others
    # Remote: SSL required, SCRAM authentication — no non-SSL remote access
    authentication = lib.mkForce ''
      local     all       postgres                 peer
      local     all       all                      scram-sha-256
      hostssl   all       all       0.0.0.0/0      scram-sha-256
      hostssl   all       all       ::/0           scram-sha-256
    '';
  };

  # ════════════════════════════════════════════════════════════════════════
  # §2  ACME / Let's Encrypt (DNS-01 via Cloudflare)
  # ════════════════════════════════════════════════════════════════════════
  security.acme = {
    acceptTerms = true;
    defaults.email = variables.useremail;
    certs.${acmeDomain} = {
      dnsProvider = "cloudflare";
      environmentFile = config.sops.templates."cloudflare-dns-env".path;
      group = "postgres"; # cert files readable by postgres
      reloadServices = ["postgresql"]; # reload PG on cert renewal
    };
  };

  # PostgreSQL must start after ACME obtains the certificate
  systemd.services.postgresql = {
    after = ["acme-${acmeDomain}.service"];
    wants = ["acme-${acmeDomain}.service"];
    # Give enough time for initial backup in postStart
    serviceConfig.TimeoutStartSec = lib.mkForce "3600";
  };

  # ════════════════════════════════════════════════════════════════════════
  # §3  Sops Secrets & Templates
  # ════════════════════════════════════════════════════════════════════════

  # -- Secret declarations --
  sops.secrets = {
    pg_superuser_password = {
      owner = "postgres";
      group = "postgres";
    };
    pg_backup_hc_url = {
      owner = "postgres";
      group = "postgres";
    };
    pgbackrest_repo_cipher_pass = {
      owner = "postgres";
      group = "postgres";
    };
    pgbackrest_s3_key = {
      owner = "postgres";
      group = "postgres";
    };
    pgbackrest_s3_key_secret = {
      owner = "postgres";
      group = "postgres";
    };
    pgbackrest_s3_endpoint = {
      owner = "postgres";
      group = "postgres";
    };
    pgbackrest_s3_bucket = {
      owner = "postgres";
      group = "postgres";
    };
    pgbackrest_s3_region = {
      owner = "postgres";
      group = "postgres";
    };
    pgbackrest_s3_path = {
      owner = "postgres";
      group = "postgres";
    };
    cloudflare_dns_api_token = {};
  };

  # -- Cloudflare environment file for ACME --
  sops.templates."cloudflare-dns-env" = {
    content = "CF_DNS_API_TOKEN=${config.sops.placeholder.cloudflare_dns_api_token}";
    mode = "0400";
  };

  # -- pgBackRest configuration (S3-only, encrypted) --
  sops.templates."pgbackrest.conf" = {
    content = lib.concatStringsSep "\n" [
      "[global]"
      "repo1-type=s3"
      "repo1-s3-key=${config.sops.placeholder.pgbackrest_s3_key}"
      "repo1-s3-key-secret=${config.sops.placeholder.pgbackrest_s3_key_secret}"
      "repo1-s3-endpoint=${config.sops.placeholder.pgbackrest_s3_endpoint}"
      "repo1-s3-bucket=${config.sops.placeholder.pgbackrest_s3_bucket}"
      "repo1-s3-region=${config.sops.placeholder.pgbackrest_s3_region}"
      "repo1-path=${config.sops.placeholder.pgbackrest_s3_path}"
      "repo1-cipher-type=aes-256-cbc"
      "repo1-cipher-pass=${config.sops.placeholder.pgbackrest_repo_cipher_pass}"
      "repo1-retention-full=4"
      "repo1-retention-diff=6"
      "repo1-retention-archive-type=full"
      "repo1-retention-archive=4"
      "compress-type=lz4"
      "compress-level=6"
      "process-max=2"
      "log-level-console=info"
      "log-level-file=detail"
      "log-path=${pgDataDir}/pgbackrest-log"
      "start-fast=y"
      "delta=y"
      ""
      "[${stanzaName}]"
      "pg1-path=${pgDataDir}"
      "pg1-port=${toString config.services.postgresql.settings.port}"
      "pg1-socket-path=/run/postgresql"
    ];
    owner = "postgres";
    group = "postgres";
    mode = "0400";
  };

  # ════════════════════════════════════════════════════════════════════════
  # §4  PostgreSQL preStart / postStart Hooks
  # ════════════════════════════════════════════════════════════════════════

  # Copy Let's Encrypt certificates to be owned by postgres
  # and create pgBackRest stanza on first boot after initdb
  systemd.services.postgresql.preStart = lib.mkAfter ''
    mkdir -p ${pgDataDir}/certs
    cp ${acmeCertDir}/fullchain.pem ${pgDataDir}/certs/fullchain.pem
    cp ${acmeCertDir}/key.pem ${pgDataDir}/certs/key.pem
    chmod 600 ${pgDataDir}/certs/key.pem

    if [ -f "${pgDataDir}/global/pg_control" ]; then
      if ! ${pgbackrestCmd} info >/dev/null 2>&1; then
        echo "pgBackRest: Creating stanza '${stanzaName}'..."
        ${pgbackrestCmd} stanza-create --no-online
        echo "pgBackRest: Stanza created successfully."
      fi
    fi
  '';

  # Set superuser password + take initial backup after PostgreSQL starts
  systemd.services.postgresql.postStart = let
    jqFilter = ".[0].backup // [] | length";
  in
    lib.mkAfter ''
      PW=$(${pkgs.coreutils}/bin/tr -d '\n' < "${config.sops.secrets.pg_superuser_password.path}")
      echo "ALTER USER postgres WITH PASSWORD :'pw';" | PGPASSWORD_NEW="$PW" ${pgPackage}/bin/psql -p ${toString config.services.postgresql.settings.port} -d postgres -v pw="$PW" >/dev/null 2>&1
      echo "PostgreSQL: Superuser password synchronized from sops."

      if ! ${pgbackrestCmd} info >/dev/null 2>&1; then
        echo "pgBackRest: Creating stanza '${stanzaName}'..."
        ${pgbackrestCmd} stanza-create
        echo "pgBackRest: Stanza created successfully."
      fi

      BACKUP_INFO=$(${pgbackrestCmd} info --output=json 2>/dev/null || echo "[]")
      BACKUP_COUNT=$(echo "$BACKUP_INFO" | ${jq} -r '${jqFilter}' 2>/dev/null || echo "0")

      if [ "$BACKUP_COUNT" = "0" ] || [ "$BACKUP_COUNT" = "null" ] || [ -z "$BACKUP_COUNT" ]; then
        echo "pgBackRest: No backups found. Taking initial full backup..."
        ${pgbackrestCmd} backup --type=full
        echo "pgBackRest: Verifying initial backup..."
        ${pgbackrestCmd} check
        echo "pgBackRest: Initial backup completed and verified."
      fi
    '';

  # ════════════════════════════════════════════════════════════════════════
  # §5  Pre-Start Services (run before PostgreSQL)
  # ════════════════════════════════════════════════════════════════════════

  systemd.services.pgbackrest-repo-validate = {
    description = "Validate pgBackRest S3 repository accessibility";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    before = ["postgresql.service" "pgbackrest-auto-restore.service"];
    requiredBy = ["postgresql.service"];

    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      Group = "postgres";
      RemainAfterExit = true;
    };

    script = ''
      set -euo pipefail
      echo "=== pgBackRest Repository Validation ==="

      OUTPUT=$(${pgbackrestBase} info 2>&1) || {
        echo "FATAL: Cannot access S3 backup repository"
        echo "Error output:"
        echo "$OUTPUT"
        echo ""
        echo "Check these sops secrets:"
        echo "  - pgbackrest_s3_key"
        echo "  - pgbackrest_s3_key_secret"
        echo "  - pgbackrest_s3_endpoint"
        echo "  - pgbackrest_s3_bucket"
        echo "  - pgbackrest_s3_region"
        echo "  - pgbackrest_s3_path"
        echo "  - pgbackrest_repo_cipher_pass"
        exit 1
      }

      echo "S3 repository is accessible."
      echo "$OUTPUT"
      echo "=== Validation passed ==="
    '';
  };

  systemd.services.pgbackrest-auto-restore = let
    jqFilter = ".[0].backup // [] | length";
  in {
    description = "Automatic PostgreSQL restore from pgBackRest S3 backup";
    after = ["network-online.target" "pgbackrest-repo-validate.service"];
    wants = ["network-online.target"];
    requires = ["pgbackrest-repo-validate.service"];
    before = ["postgresql.service"];
    requiredBy = ["postgresql.service"];

    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      Group = "postgres";
      RemainAfterExit = true;
      TimeoutStartSec = "infinity"; # restore can take a long time
      # Ensure data directory exists with correct ownership (+ = run as root)
      ExecStartPre = ["+${install} -d -m 0700 -o postgres -g postgres ${pgDataDir}"];
    };

    script = ''
      set -euo pipefail
      echo "=== pgBackRest Auto-Restore Check ==="

      if [ -f "${pgDataDir}/PG_VERSION" ]; then
        echo "PostgreSQL data directory is initialized. Skipping restore."
        exit 0
      fi

      echo "PostgreSQL data directory is empty or uninitialized."

      BACKUP_INFO=$(${pgbackrestCmd} info --output=json 2>/dev/null || echo "[]")
      BACKUP_COUNT=$(echo "$BACKUP_INFO" | ${jq} -r '${jqFilter}' 2>/dev/null || echo "0")

      if [ "$BACKUP_COUNT" = "0" ] || [ "$BACKUP_COUNT" = "null" ] || [ -z "$BACKUP_COUNT" ]; then
        echo "No backups found in repository. This is a fresh installation."
        echo "PostgreSQL will initialize a new cluster."
        exit 0
      fi

      echo "Found $BACKUP_COUNT backup(s). Restoring from latest backup..."

      ${pgbackrestCmd} restore --delta

      echo "=== Restore completed successfully ==="
    '';
  };

  # ════════════════════════════════════════════════════════════════════════
  # §6  Scheduled Backup Services (with healthcheck notifications)
  # ════════════════════════════════════════════════════════════════════════

  systemd.services.pgbackrest-full-backup = {
    description = "pgBackRest Full Backup";
    after = ["postgresql.service"];
    requires = ["postgresql.service"];

    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      Group = "postgres";
    };

    script = mkBackupScript {type = "full";};
  };

  systemd.services.pgbackrest-diff-backup = {
    description = "pgBackRest Differential Backup";
    after = ["postgresql.service"];
    requires = ["postgresql.service"];

    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      Group = "postgres";
    };

    script = mkBackupScript {type = "diff";};
  };

  systemd.services.pgbackrest-incr-backup = {
    description = "pgBackRest Incremental Backup";
    after = ["postgresql.service"];
    requires = ["postgresql.service"];

    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      Group = "postgres";
    };

    script = mkBackupScript {
      type = "incr";
      runExpire = false; # expire runs on full/diff only
    };
  };

  # ════════════════════════════════════════════════════════════════════════
  # §7  Backup Verification Service
  # ════════════════════════════════════════════════════════════════════════

  systemd.services.pgbackrest-verify = {
    description = "pgBackRest Backup Verification (restore test)";
    after = ["postgresql.service"];
    requires = ["postgresql.service"];

    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      Group = "postgres";
      TimeoutStartSec = "7200"; # 2 hours max
    };

    path = [pgPackage pgBackRest pkgs.coreutils];

    script = ''
      set -euo pipefail

      VERIFY_DIR=$(mktemp -d /tmp/pgbackrest-verify-XXXXXXXX)
      VERIFY_PORT=54321
      PG_BIN="${pgPackage}/bin"
      CLEANUP_DONE=0

      cleanup() {
        if [ "$CLEANUP_DONE" = "1" ]; then return; fi
        CLEANUP_DONE=1
        echo "Cleaning up verification environment..."
        "$PG_BIN/pg_ctl" -D "$VERIFY_DIR" stop -m immediate 2>/dev/null || true
        rm -rf "$VERIFY_DIR"
      }
      trap cleanup EXIT

      echo "========================================"
      echo "  pgBackRest Backup Verification"
      echo "  Timestamp: $(date -Is)"
      echo "  Temp dir:  $VERIFY_DIR"
      echo "========================================"

      echo ""
      echo "[1/5] Restoring latest backup to temporary directory..."
      ${pgbackrestCmd} restore \
        --pg1-path="$VERIFY_DIR" \
        --delta

      echo "[2/5] Configuring temporary PostgreSQL instance..."
      {
        echo "port = $VERIFY_PORT"
        echo "archive_mode = off"
        echo "archive_command = /bin/true"
        echo "listen_addresses = "
        echo "unix_socket_directories = $VERIFY_DIR"
        echo "logging_collector = off"
        echo "ssl = off"
      } >> "$VERIFY_DIR/postgresql.conf"

      rm -f "$VERIFY_DIR/recovery.signal" "$VERIFY_DIR/standby.signal"

      echo "[3/5] Starting temporary PostgreSQL instance..."
      "$PG_BIN/pg_ctl" -D "$VERIFY_DIR" start -w -t 120

      echo "[4/5] Running health checks..."
      "$PG_BIN/psql" -h "$VERIFY_DIR" -p "$VERIFY_PORT" -U postgres -d postgres -c "SELECT 1 AS health_check;"
      "$PG_BIN/psql" -h "$VERIFY_DIR" -p "$VERIFY_PORT" -U postgres -d postgres -c "SELECT version() AS pg_version;"
      "$PG_BIN/psql" -h "$VERIFY_DIR" -p "$VERIFY_PORT" -U postgres -d postgres -c "SELECT pg_is_in_recovery() AS is_recovering;"
      "$PG_BIN/psql" -h "$VERIFY_DIR" -p "$VERIFY_PORT" -U postgres -d postgres -c "SELECT count(*) AS total_relations FROM pg_class;"

      echo "[5/5] Stopping temporary instance..."
      "$PG_BIN/pg_ctl" -D "$VERIFY_DIR" stop -m fast
      rm -rf "$VERIFY_DIR"
      CLEANUP_DONE=1

      echo ""
      echo "========================================"
      echo "  VERIFICATION PASSED"
      echo "========================================"
    '';
  };

  # ════════════════════════════════════════════════════════════════════════
  # §8  Systemd Timers
  # ════════════════════════════════════════════════════════════════════════

  systemd.timers.pgbackrest-full-backup = {
    description = "Weekly full backup (Sunday 01:00)";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "Sun *-*-* 01:00:00";
      Persistent = true;
      RandomizedDelaySec = "5m";
    };
  };

  systemd.timers.pgbackrest-diff-backup = {
    description = "Daily differential backup (Mon-Sat 01:00)";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "Mon..Sat *-*-* 01:00:00";
      Persistent = true;
      RandomizedDelaySec = "5m";
    };
  };

  systemd.timers.pgbackrest-incr-backup = {
    description = "Hourly incremental backup (except 01:00)";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "*-*-* 00,02..23:00:00";
      Persistent = true;
      RandomizedDelaySec = "2m";
    };
  };

  systemd.timers.pgbackrest-verify = {
    description = "Weekly backup verification (Saturday 03:00)";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "Sat *-*-* 03:00:00";
      Persistent = true;
      RandomizedDelaySec = "10m";
    };
  };

  # ════════════════════════════════════════════════════════════════════════
  # §9  System Configuration
  # ════════════════════════════════════════════════════════════════════════

  # pgBackRest CLI available for manual operations
  environment.systemPackages = [pgBackRest];

  # Ensure pgBackRest log directory exists with correct ownership
  systemd.tmpfiles.rules = [
    "d ${pgDataDir}/pgbackrest-log 0750 postgres postgres -"
  ];
}
