# blackbox-exporter — HTTP/TCP probes and TLS certificate checks
# Always enabled when monitoring is active.
# Two instances exist in the architecture:
#   - Robin: probes localhost endpoints (internal health)
#   - Zoro: probes public URLs (external path including DNS, TLS, nginx)
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
  config = lib.mkIf cfg.enable {
    services.prometheus.exporters.blackbox = {
      enable = true;
      port = 9115;
      listenAddress = listenAddr;
      configFile = (builtins.toFile "blackbox.yml" (builtins.toJSON {
        modules = {
          # HTTP probe — check if endpoint returns 2xx
          http_2xx = {
            prober = "http";
            timeout = "10s";
            http = {
              valid_http_versions = ["HTTP/1.1" "HTTP/2.0"];
              valid_status_codes = []; # defaults to 2xx
              follow_redirects = true;
              preferred_ip_protocol = "ip4";
            };
          };
          # HTTP probe — accept any successful status (including 204)
          http_2xx_no_body = {
            prober = "http";
            timeout = "10s";
            http = {
              valid_http_versions = ["HTTP/1.1" "HTTP/2.0"];
              valid_status_codes = [200 204];
              method = "HEAD";
              preferred_ip_protocol = "ip4";
            };
          };
          # TLS probe — check certificate validity and expiry
          tls_connect = {
            prober = "tcp";
            timeout = "10s";
            tcp = {
              tls = true;
              preferred_ip_protocol = "ip4";
            };
          };
          # TCP probe — check if port is open
          tcp_connect = {
            prober = "tcp";
            timeout = "5s";
          };
          # ICMP probe — check if host is reachable
          icmp = {
            prober = "icmp";
            timeout = "5s";
          };
        };
      }));
    };
  };
}
