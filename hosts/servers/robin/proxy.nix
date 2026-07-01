# ACME / Let's Encrypt configuration (DNS-01 via Cloudflare)
# Provisions certificates for PostgreSQL, Nginx, and Ente.
{
  config,
  variables,
  ...
}: let
  acmeDomainPg = "db.vjlab.dev";
  acmeDomainNginx = "vjlab.dev";
  acmeDomainEnte = "ente.vjlab.dev";
in {
  # ── ACME Configuration ──────────────────────────────────────────────────
  security.acme = {
    acceptTerms = true;
    defaults.email = variables.useremail;

    certs = {
      # Certificate for PostgreSQL
      "${acmeDomainPg}" = {
        dnsProvider = "cloudflare";
        environmentFile = config.sops.templates."cloudflare-dns-env".path;
        group = "postgres";
      };

      # Wildcard Certificate for Nginx (covers vjlab.dev and *.vjlab.dev)
      "${acmeDomainNginx}" = {
        domain = "vjlab.dev";
        extraDomainNames = ["*.vjlab.dev"];
        dnsProvider = "cloudflare";
        environmentFile = config.sops.templates."cloudflare-dns-env".path;
        group = config.services.nginx.group;
      };

      # Wildcard Certificate for Ente (covers ente.vjlab.dev and *.ente.vjlab.dev)
      "${acmeDomainEnte}" = {
        domain = "ente.vjlab.dev";
        extraDomainNames = ["*.ente.vjlab.dev"];
        dnsProvider = "cloudflare";
        environmentFile = config.sops.templates."cloudflare-dns-env".path;
        group = config.services.nginx.group;
      };
    };
  };
  # ── Nginx Core Settings ────────────────────────────────────────────────
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
  };

  # Open HTTP and HTTPS ports
  networking.firewall.allowedTCPPorts = [80 443];

  # ── SOPS secrets & templates for Cloudflare DNS ─────────────────────────
  sops.secrets.cloudflare_dns_api_token = {};

  sops.templates."cloudflare-dns-env" = {
    content = "CF_DNS_API_TOKEN=${config.sops.placeholder.cloudflare_dns_api_token}";
    mode = "0400";
  };
}
