# Nginx TLS proxy for Zoro monitoring UIs
# Hub only. Configures Nginx virtual hosts with TLS for:
#   - grafana.zoro.vjlab.dev -> localhost:3000
#   - prometheus.zoro.vjlab.dev -> localhost:9090
#   - alertmanager.zoro.vjlab.dev -> localhost:9093
{
  config,
  lib,
  variables,
  ...
}: let
  cfg = config.services.monitoring;
  baseDomain = cfg.hub.domain;
  wildcardDomain = "*.${baseDomain}";
in {
  config = lib.mkIf (cfg.enable && cfg.role == "hub") {
    # ── Cloudflare DNS secrets ──────────────────────────────────────────
    sops.secrets.cloudflare_dns_api_token = {};

    sops.templates."cloudflare-dns-env-zoro" = {
      content = "CF_DNS_API_TOKEN=${config.sops.placeholder.cloudflare_dns_api_token}";
      mode = "0400";
    };

    # ── ACME Configuration ──────────────────────────────────────────────
    security.acme = {
      acceptTerms = true;
      defaults.email = variables.useremail;

      certs."${baseDomain}" = {
        domain = baseDomain;
        extraDomainNames = [wildcardDomain];
        dnsProvider = "cloudflare";
        environmentFile = config.sops.templates."cloudflare-dns-env-zoro".path;
        group = config.services.nginx.group;
      };
    };

    # ── Nginx Service ───────────────────────────────────────────────────
    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts = {
        "grafana.${baseDomain}" = {
          useACMEHost = baseDomain;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:3000";
            proxyWebsockets = true;
          };
        };

        "prometheus.${baseDomain}" = {
          useACMEHost = baseDomain;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:9090";
          };
        };

        "alertmanager.${baseDomain}" = {
          useACMEHost = baseDomain;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:9093";
          };
        };
      };
    };

    # Open Nginx ports in firewall (Zoro is local but should expose HTTP/HTTPS to local network)
    networking.firewall.allowedTCPPorts = [80 443];
  };
}
