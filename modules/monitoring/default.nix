# Monitoring stack — top-level module with custom options
#
# Usage:
#   services.monitoring.enable = true;
#   services.monitoring.role = "exporter";  # or "hub"
#
# Exporter role: installs exporters + promtail on the host
# Hub role: installs Prometheus, Loki, Alertmanager, Grafana + local exporters
{
  config,
  lib,
  ...
}: {
  imports = [
    ./wireguard.nix
    ./logging.nix
    ./exporters/node-exporter.nix
    ./exporters/postgres-exporter.nix
    ./exporters/pgbackrest-exporter.nix
    ./exporters/restic-exporter.nix
    ./exporters/nginx-exporter.nix
    ./exporters/systemd-exporter.nix
    ./exporters/blackbox-exporter.nix
    ./exporters/fail2ban-exporter.nix
    ./exporters/wireguard-exporter.nix
    ./prometheus.nix
    ./loki.nix
    ./alertmanager.nix
    ./grafana.nix
    ./nginx-proxy.nix
  ];

  options.services.monitoring = {
    enable = lib.mkEnableOption "monitoring stack";

    role = lib.mkOption {
      type = lib.types.enum ["exporter" "hub"];
      description = "Whether this host exports metrics or runs the monitoring hub";
    };

    wireguard = {
      enable = lib.mkEnableOption "WireGuard monitoring tunnel";

      address = lib.mkOption {
        type = lib.types.str;
        description = "This host's WireGuard IP (e.g. 10.100.0.1/24)";
        example = "10.100.0.1/24";
      };

      privateKeySecret = lib.mkOption {
        type = lib.types.str;
        description = "Sops secret name for this host's WireGuard private key";
        example = "wg_monitor_robin_private_key";
      };

      # peerPublicKey is defined in wireguard.nix (plain text, not a secret)

      peerEndpointSecret = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Sops secret name for peer's public endpoint (IP:port). Only needed by the initiating side (Zoro).";
        example = "robin_public_endpoint";
      };

      listenPort = lib.mkOption {
        type = lib.types.int;
        default = 41641;
        description = "WireGuard UDP listen port (non-standard to confuse bots)";
      };

      peerAllowedIPs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = ["10.100.0.0/24"];
        description = "Allowed IPs for the WireGuard peer";
      };
    };

    exporters = {
      postgresql.enable = lib.mkEnableOption "PostgreSQL exporter";
      pgbackrest.enable = lib.mkEnableOption "pgBackRest exporter";
      restic.enable = lib.mkEnableOption "Restic exporter";
      nginx.enable = lib.mkEnableOption "Nginx exporter";
      fail2ban.enable = lib.mkEnableOption "fail2ban exporter";
      wireguard.enable = lib.mkEnableOption "WireGuard exporter";
      # node-exporter and systemd-exporter are always enabled
    };

    # Hub-only options
    hub = {
      domain = lib.mkOption {
        type = lib.types.str;
        default = "${config.networking.hostName}.vjlab.dev";
        description = "Base domain for monitoring UIs (uses hostname for portability)";
      };
    };

    targets = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          host = lib.mkOption {
            type = lib.types.str;
            description = "IP or hostname of the target";
          };
          name = lib.mkOption {
            type = lib.types.str;
            description = "Human-readable name for the target";
          };
          exporters = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            description = "List of exporter names enabled on this target";
            example = ["node" "postgres" "pgbackrest" "restic" "nginx" "systemd" "blackbox" "fail2ban"];
          };
        };
      });
      default = [];
      description = "Scrape targets (hub only)";
    };
  };
}
