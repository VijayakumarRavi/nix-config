# nginx-exporter — Nginx metrics from stub_status
# Conditional: only enabled when services.monitoring.exporters.nginx.enable = true
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
  config = lib.mkIf (cfg.enable && cfg.exporters.nginx.enable) {
    services.prometheus.exporters.nginx = {
      enable = true;
      port = 9113;
      listenAddress = listenAddr;
      scrapeUri = "http://127.0.0.1/nginx_status";
    };

    # ── Nginx stub_status endpoint ──────────────────────────────────────
    # Required for nginx-exporter to read metrics.
    # Restricted to localhost and WireGuard subnet.
    services.nginx.virtualHosts."_" = {
      locations."/nginx_status" = {
        extraConfig = ''
          stub_status;
          allow 127.0.0.1;
          allow 10.100.0.0/24;
          deny all;
        '';
      };
    };
  };
}
