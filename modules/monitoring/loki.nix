# Loki — log aggregation
# Hub only: receives logs from Promtail agents.
{
  config,
  lib,
  ...
}: let
  cfg = config.services.monitoring;
in {
  config = lib.mkIf (cfg.enable && cfg.role == "hub") {
    services.loki = {
      enable = true;
      configuration = {
        server = {
          http_listen_port = 3100;
          grpc_listen_port = 9096;
          # Listen on all interfaces for WireGuard access
          http_listen_address = "0.0.0.0";
        };

        auth_enabled = false;

        common = {
          path_prefix = "/var/lib/loki";
          ring = {
            instance_addr = "127.0.0.1";
            kvstore.store = "inmemory";
          };
          replication_factor = 1;
        };

        schema_config = {
          configs = [
            {
              from = "2024-01-01";
              store = "tsdb";
              object_store = "filesystem";
              schema = "v13";
              index = {
                prefix = "index_";
                period = "24h";
              };
            }
          ];
        };

        storage_config = {
          filesystem = {
            directory = "/var/lib/loki/chunks";
          };
          tsdb_shipper = {
            active_index_directory = "/var/lib/loki/tsdb-index";
            cache_location = "/var/lib/loki/tsdb-cache";
          };
        };

        limits_config = {
          retention_period = "336h"; # 14 days
          reject_old_samples = true;
          reject_old_samples_max_age = "168h"; # 7 days
          max_query_series = 5000;
          ingestion_rate_mb = 10;
          ingestion_burst_size_mb = 20;
        };

        compactor = {
          working_directory = "/var/lib/loki/compactor";
          compaction_interval = "10m";
          retention_enabled = true;
          retention_delete_delay = "2h";
          delete_request_store = "filesystem";
        };

        analytics.reporting_enabled = false;
      };
    };

    # ── Firewall: allow Loki from WireGuard ───────────────────────────
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.wireguard.enable [3100];
  };
}
