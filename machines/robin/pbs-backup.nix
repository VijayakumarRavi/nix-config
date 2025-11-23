{
  pkgs,
  config,
  ...
}: let
  dobackup = pkgs.writeShellScriptBin "dobackup" ''
    set -euo pipefail

    # configuration
    SPEC=""
    SPEC="$SPEC projects.pxar:/opt/docker/projects"

    KEYFILE="${config.sops.secrets.pbs-encryption.path}"
    LOCKDIR="/var/lock/pbs-backup"
    FLockFile="$LOCKDIR/backup.lock"

    # ensure directory exists
    mkdir -p "$LOCKDIR"
    umask 027

    # quick sanity checks
    if [ ! -r "$KEYFILE" ]; then
      echo "$(date -u +%FT%TZ) ERROR: keyfile $KEYFILE not readable"
      exit 2
    fi

    # run with flock to avoid overlapping runs (10 minute timeout)
    exec 9>"$FLockFile"
    if ! ${pkgs.util-linux}/bin/flock -n -w 600 9; then
      echo "$(date -u +%FT%TZ) INFO: Another backup running; exiting"
      exit 0
    fi

    # run backup and log stdout/stderr (keep exit code)
    echo "$(date -u +%FT%TZ) INFO: Starting backup"
    if ${pkgs.proxmox-backup-client}/bin/proxmox-backup-client  backup $SPEC --all-file-systems true --keyfile $KEYFILE --change-detection-mode metadata; then
      echo "$(date -u +%FT%TZ) INFO: Backup completed successfully"
      latest=$(${pkgs.proxmox-backup-client}/bin/proxmox-backup-client snapshot list --output-format json | ${pkgs.jq}/bin/jq -r 'map(select(.["backup-type"]=="host" and .["backup-id"]=="robin")) | if length==0 then empty else max_by(.["backup-time"]) | "\(.["backup-type"])/\(.["backup-id"])/\(.["backup-time"]|todateiso8601)" end')
      if [ -n "$latest" ]; then
        ${pkgs.proxmox-backup-client}/bin/proxmox-backup-client  snapshot notes update "$latest" "Automatic backup: $(date -u +%Y-%m-%dT%H:%M:%SZ)" || true
      fi
      exit 0
    else
      rc=$?
      echo "$(date -u +%FT%TZ) ERROR: Backup failed (exit $rc)"
      exit $rc
    fi
  '';
in {
  systemd.timers.pbs-backup = {
    description = "PBS Backup Timer";
    wantedBy = ["timers.target"];
    wants = ["network-online.target"];
    timerConfig = {
      OnCalendar = "*-*-* *:30:00";
      Persistent = true;
      RandomizedDelaySec = 300;
    };
  };

  systemd.services.pbs-backup = {
    description = "PBS Backup Service";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${dobackup}/bin/dobackup";
      EnvironmentFile = "${config.sops.secrets.pbs-creds.path}";
      Nice = "10";
      IOSchedulingClass = "best-effort";
      IOSchedulingPriority = "7";
    };
  };
}
