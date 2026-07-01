# Grafana — visualization and dashboarding
# Hub only. Configures datasources (Prometheus, Loki) and dashboard provisioning.
{
  config,
  lib,
  ...
}: let
  cfg = config.services.monitoring;
in {
  config = lib.mkIf (cfg.enable && cfg.role == "hub") {
    # ── Sops secrets for Grafana ─────────────────────────────────────────
    sops.secrets.grafana_secret_key = {
      owner = "grafana";
      group = "grafana";
    };

    # OAuth Secrets (Pocket ID)
    sops.secrets.grafana_client_id = {
      owner = "grafana";
      group = "grafana";
    };
    sops.secrets.grafana_client_secret = {
      owner = "grafana";
      group = "grafana";
    };
    sops.secrets.grafana_oauth_api_url = {
      owner = "grafana";
      group = "grafana";
    };
    sops.secrets.grafana_oauth_auth_url = {
      owner = "grafana";
      group = "grafana";
    };
    sops.secrets.grafana_oauth_token_url = {
      owner = "grafana";
      group = "grafana";
    };
    sops.secrets.grafana_signout_redirect_url = {
      owner = "grafana";
      group = "grafana";
    };

    # ── Environment file for Grafana (runtime secret injection) ──────────
    sops.templates."grafana-env" = {
      owner = "grafana";
      group = "grafana";
      content = ''
        GF_AUTH_GENERIC_OAUTH_API_URL=${config.sops.placeholder.grafana_oauth_api_url}
        GF_AUTH_GENERIC_OAUTH_AUTH_URL=${config.sops.placeholder.grafana_oauth_auth_url}
        GF_AUTH_GENERIC_OAUTH_CLIENT_ID=${config.sops.placeholder.grafana_client_id}
        GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET=${config.sops.placeholder.grafana_client_secret}
        GF_AUTH_GENERIC_OAUTH_TOKEN_URL=${config.sops.placeholder.grafana_oauth_token_url}
        GF_AUTH_SIGNOUT_REDIRECT_URL=${config.sops.placeholder.grafana_signout_redirect_url}
      '';
    };

    # ── Grafana Service ──────────────────────────────────────────────────
    services.grafana = {
      enable = true;
      settings = {
        server = {
          http_addr = "127.0.0.1";
          http_port = 3000;
          domain = "${cfg.hub.domain}";
          root_url = "https://grafana.${cfg.hub.domain}/";
        };
        security = {
          cookie_secure = true;
          secret_key = "$__file{${config.sops.secrets.grafana_secret_key.path}}";
        };
        auth = {
          oauth_auto_login = true;
        };
        "auth.generic_oauth" = {
          enabled = true;
          name = "Pocket ID";
          scopes = "openid profile email groups";
          role_attribute_path = "contains(groups, 'admins')&& 'Admin' || contains(groups, 'editors') && 'Editor' || 'Viewer'";
        };
        analytics.reporting_enabled = false;
        dashboards = {
          default_home_dashboard_path = "/etc/grafana-dashboards/overview.json";
        };
      };

      # ── Provisioning Datasources ───────────────────────────────────────
      provision.datasources.settings = {
        apiVersion = 1;
        datasources = [
          {
            name = "Prometheus";
            uid = "Prometheus";
            type = "prometheus";
            access = "proxy";
            url = "http://127.0.0.1:9090";
            isDefault = true;
            jsonData = {
              timeInterval = "15s";
            };
          }
          {
            name = "Loki";
            uid = "Loki";
            type = "loki";
            access = "proxy";
            url = "http://127.0.0.1:3100";
            jsonData = {
              maxLines = 1000;
            };
          }
          {
            name = "Alertmanager";
            uid = "Alertmanager";
            type = "alertmanager";
            access = "proxy";
            url = "http://127.0.0.1:9093";
            jsonData = {
              implementation = "prometheus";
              handleGrafanaManagedAlerts = true;
            };
          }
        ];
      };

      # ── Provisioning Dashboards ────────────────────────────────────────
      # We load dashboards from our custom dashboard directory
      provision.dashboards.settings = {
        apiVersion = 1;
        providers = [
          {
            name = "Provisioned Dashboards";
            options.path = "/etc/grafana-dashboards";
          }
        ];
      };
    };

    systemd.services.grafana.serviceConfig.EnvironmentFile = [config.sops.templates."grafana-env".path];

    environment.etc = {
      "grafana-dashboards/node.json".source = ./grafana-dashboards/node.json;
      "grafana-dashboards/postgresql.json".source = ./grafana-dashboards/postgresql.json;
      "grafana-dashboards/nginx.json".source = ./grafana-dashboards/nginx.json;
      "grafana-dashboards/loki.json".source = ./grafana-dashboards/loki.json;
      "grafana-dashboards/pgbackrest.json".source = ./grafana-dashboards/pgbackrest.json;
      "grafana-dashboards/overview.json".source = ./grafana-dashboards/overview.json;
      "grafana-dashboards/backups.json".source = ./grafana-dashboards/backups.json;
      "grafana-dashboards/applications.json".source = ./grafana-dashboards/applications.json;
      "grafana-dashboards/systemd.json".source = ./grafana-dashboards/systemd.json;
      "grafana-dashboards/alerts.json".source = ./grafana-dashboards/alerts.json;
      "grafana-dashboards/fail2ban.json".source = ./grafana-dashboards/fail2ban.json;
    };
  };
}
