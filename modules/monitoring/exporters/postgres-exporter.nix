# postgres-exporter — PostgreSQL metrics
# Conditional: only enabled when services.monitoring.exporters.postgresql.enable = true
{
  config,
  lib,
  ...
}: let
  cfg = config.services.monitoring;
  listenAddr =
    if cfg.wireguard.enable
    then lib.head (builtins.match "([^/]+)/.*" cfg.wireguard.address)
    else "127.0.0.1";
in {
  config = lib.mkIf (cfg.enable && cfg.exporters.postgresql.enable) {
    services.prometheus.exporters.postgres = {
      enable = true;
      runAsLocalSuperUser = true;
      port = 9187;
      listenAddress = listenAddr;
      # Connect via Unix socket — no password needed (peer auth)
      dataSourceName = "user=postgres host=/run/postgresql port=${toString config.services.postgresql.port} dbname=postgres sslmode=disable";
      extraFlags = [
        "--auto-discover-databases"
      ];
    };
  };
}
