# Prometheus — metrics collection, scraping, and alerting
# Hub only: scrapes all configured targets via WireGuard + local exporters.
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.monitoring;

  # ── Generate scrape configs from targets ──────────────────────────────
  # Map exporter names to their ports
  exporterPorts = {
    node = 9100;
    postgres = 9187;
    pgbackrest = 9854;
    restic = 9753;
    nginx = 9113;
    systemd = 9558;
    blackbox = 9115;
    fail2ban = 9100; # Uses node-exporter's textfile collector, not a separate port
  };

  # Generate a scrape job for each exporter type across all targets
  mkScrapeJob = exporterName: port: let
    targetsWithExporter =
      builtins.filter
      (t: builtins.elem exporterName t.exporters)
      cfg.targets;
  in
    lib.optionalAttrs (targetsWithExporter != []) {
      job_name = exporterName;
      scrape_interval = "15s";
      static_configs =
        map (t: {
          targets = ["${t.host}:${toString port}"];
          labels = {
            instance = t.name;
            host = t.name;
          };
        })
        targetsWithExporter;
    };

  # Build scrape configs (excluding blackbox which has special handling)
  standardScrapeJobs = lib.filter (j: j != {}) (
    lib.mapAttrsToList (
      name: port:
        if name == "blackbox" || name == "fail2ban"
        then {}
        else mkScrapeJob name port
    )
    exporterPorts
  );

  # ── Blackbox probe scrape configs ─────────────────────────────────────
  blackboxScrapeJobs = [
    # Internal probes from Robin's blackbox-exporter
    {
      job_name = "blackbox-internal";
      scrape_interval = "30s";
      metrics_path = "/probe";
      params.module = ["http_2xx"];
      static_configs = [
        {
          targets = [
            "http://127.0.0.1:8080/ping" # Ente (internal)
            "http://127.0.0.1:1411/" # Pocket ID (internal)
            "http://127.0.0.1:17170/" # LLDAP (internal)
          ];
          labels.host = "robin";
          labels.probe_type = "internal";
        }
      ];
      relabel_configs = [
        {
          source_labels = ["__address__"];
          target_label = "__param_target";
        }
        {
          source_labels = ["__param_target"];
          target_label = "instance";
        }
        {
          target_label = "__address__";
          replacement = "10.100.0.1:9115";
        }
      ];
    }
    # External probes from Zoro's blackbox-exporter
    {
      job_name = "blackbox-external";
      scrape_interval = "60s";
      metrics_path = "/probe";
      params.module = ["http_2xx"];
      static_configs = [
        {
          targets = [
            "https://auth.vjlab.dev/healthz" # Pocket ID (external)
            "https://lldap.vjlab.dev/" # LLDAP (external)
            "https://ente.vjlab.dev/ping" # Ente API (external)
          ];
          labels.probe_type = "external";
        }
      ];
      relabel_configs = [
        {
          source_labels = ["__address__"];
          target_label = "__param_target";
        }
        {
          source_labels = ["__param_target"];
          target_label = "instance";
        }
        {
          target_label = "__address__";
          replacement = "10.100.0.2:9115";
        }
      ];
    }
    # TLS certificate monitoring
    {
      job_name = "tls-certs";
      scrape_interval = "300s"; # Every 5 minutes
      metrics_path = "/probe";
      params.module = ["tls_connect"];
      static_configs = [
        {
          targets = [
            "ente.vjlab.dev:443"
            "auth.vjlab.dev:443"
            "lldap.vjlab.dev:443"
            "photos.ente.vjlab.dev:443"
            "accounts.ente.vjlab.dev:443"
            "cast.ente.vjlab.dev:443"
            "albums.ente.vjlab.dev:443"
          ];
        }
      ];
      relabel_configs = [
        {
          source_labels = ["__address__"];
          target_label = "__param_target";
        }
        {
          source_labels = ["__param_target"];
          target_label = "instance";
        }
        {
          target_label = "__address__";
          replacement = "10.100.0.2:9115";
        }
      ];
    }
  ];

  # ── Dead-man's switch ─────────────────────────────────────────────────
  # Prometheus rule that always fires + alertmanager route to HC.io
  deadmanRule = {
    name = "DeadMansSwitch";
    rules = [
      {
        alert = "DeadMansSwitch";
        expr = "vector(1)";
        labels.severity = "none";
        annotations = {
          summary = "Dead man's switch — Prometheus is alive";
          description = "This alert always fires. If it stops firing, the Prometheus stack is down.";
        };
      }
    ];
  };
in {
  config = lib.mkIf (cfg.enable && cfg.role == "hub") {
    services.prometheus = {
      enable = true;
      port = 9090;
      listenAddress = "127.0.0.1";
      retentionTime = "14d";
      globalConfig = {
        scrape_interval = "15s";
        evaluation_interval = "15s";
      };

      # Import alert rules
      ruleFiles = [
        (pkgs.writeText "node-rules.json" (builtins.toJSON (import ./alert-rules/node.nix)))
        (pkgs.writeText "postgresql-rules.json" (builtins.toJSON (import ./alert-rules/postgresql.nix)))
        (pkgs.writeText "backups-rules.json" (builtins.toJSON (import ./alert-rules/backups.nix)))
        (pkgs.writeText "nginx-rules.json" (builtins.toJSON (import ./alert-rules/nginx.nix)))
        (pkgs.writeText "systemd-rules.json" (builtins.toJSON (import ./alert-rules/systemd.nix)))
        (pkgs.writeText "tls-rules.json" (builtins.toJSON (import ./alert-rules/tls.nix)))
        (pkgs.writeText "network-rules.json" (builtins.toJSON (import ./alert-rules/network.nix)))
        (pkgs.writeText "fail2ban-rules.json" (builtins.toJSON (import ./alert-rules/fail2ban.nix)))
        (pkgs.writeText "applications-rules.json" (builtins.toJSON (import ./alert-rules/applications.nix)))
        (pkgs.writeText "self-monitoring-rules.json" (builtins.toJSON (import ./alert-rules/self-monitoring.nix)))
      ];

      # Alertmanager target
      alertmanagers = [
        {
          static_configs = [
            {targets = ["127.0.0.1:9093"];}
          ];
        }
      ];

      scrapeConfigs = standardScrapeJobs ++ blackboxScrapeJobs;

      # Dead-man's switch rule (inline)
      rules = [(builtins.toJSON {groups = [deadmanRule];})];
    };
  };
}
