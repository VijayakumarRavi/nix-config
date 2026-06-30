# Alertmanager — alert routing, deduplication, and notification
# Hub only: receives alerts from Prometheus, routes to Pushover.
{
  config,
  lib,
  ...
}: let
  cfg = config.services.monitoring;
in {
  config = lib.mkIf (cfg.enable && cfg.role == "hub") {
    # ── Sops secrets for Pushover and Healthchecks.io ──────────────────
    sops.secrets.pushover_user_key = {};
    sops.secrets.pushover_api_token = {};
    sops.secrets.zoro_hc_uuid = {};

    # ── Environment file for Alertmanager (runtime secret injection) ──
    # Interpolated via envsubst into alertmanager.yml at startup.
    sops.templates."alertmanager-env" = {
      content = ''
        PUSHOVER_USER_KEY=${config.sops.placeholder.pushover_user_key}
        PUSHOVER_API_TOKEN=${config.sops.placeholder.pushover_api_token}
        ZORO_HC_UUID=${config.sops.placeholder.zoro_hc_uuid}
      '';
    };

    services.prometheus.alertmanager = {
      enable = true;
      port = 9093;
      listenAddress = "127.0.0.1";
      environmentFile = config.sops.templates."alertmanager-env".path;

      # Structured Nix attribute set config.
      # Secrets are referenced as $VAR and expanded at startup by envsubst.
      configuration = {
        global = {
          resolve_timeout = "5m";
        };

        route = {
          receiver = "pushover-critical";
          group_by = ["alertname" "host"];
          group_wait = "30s";
          group_interval = "3m";
          repeat_interval = "4h";

          routes = [
            # Dead-man's switch -> Healthchecks.io
            {
              receiver = "deadman";
              matchers = ["alertname = DeadMansSwitch"];
              repeat_interval = "5m";
              group_wait = "0s";
            }
            # Critical alerts -> Pushover high priority
            {
              receiver = "pushover-critical";
              matchers = ["severity = critical"];
              repeat_interval = "1h";
            }
            # Warning alerts -> Pushover normal priority
            {
              receiver = "pushover-warning";
              matchers = ["severity = warning"];
              repeat_interval = "4h";
            }
          ];
        };

        receivers = [
          {
            name = "pushover-critical";
            pushover_configs = [
              {
                user_key = "$PUSHOVER_USER_KEY";
                token = "$PUSHOVER_API_TOKEN";
                priority = 1; # High priority — retry until acknowledged
                retry = "60s";
                expire = "3600s";
                title = "🚨 {{ .GroupLabels.alertname }}";
                message = "{{ range .Alerts }}{{ .Annotations.summary }}\n{{ .Annotations.description }}\n{{ end }}";
              }
            ];
          }
          {
            name = "pushover-warning";
            pushover_configs = [
              {
                user_key = "$PUSHOVER_USER_KEY";
                token = "$PUSHOVER_API_TOKEN";
                priority = 0; # Normal priority
                title = "⚠️ {{ .GroupLabels.alertname }}";
                message = "{{ range .Alerts }}{{ .Annotations.summary }}\n{{ .Annotations.description }}\n{{ end }}";
              }
            ];
          }
          {
            name = "deadman";
            webhook_configs = [
              {
                url = "https://hc-ping.com/$ZORO_HC_UUID";
                send_resolved = false;
              }
            ];
          }
        ];

        # ── Inhibition rules ──────────────────────────────────────────
        # If a host is down, suppress all service-level alerts for that host
        inhibit_rules = [
          {
            source_matchers = ["alertname = NodeDown"];
            target_matchers = ["severity =~ \"warning|critical\""];
            equal = ["host"];
          }
          {
            source_matchers = ["alertname = WireGuardTunnelDown"];
            target_matchers = ["host = \"robin\""];
            equal = [];
          }
        ];
      };

      extraFlags = [
        "--data.retention=120h"
      ];
    };
  };
}
