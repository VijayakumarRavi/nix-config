# Logging — log collection and shipping using Fluent Bit
# Reads from systemd journal and pushes to Loki.
# Fluent Bit is extremely lightweight (~10MB RAM) and EOL-safe.
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.monitoring;

  # Determine Loki push endpoint based on role
  lokiHost =
    if cfg.role == "hub"
    then "127.0.0.1"
    else "10.100.0.2";
in {
  config = lib.mkIf cfg.enable {
    # ── Fluent Bit Service ──────────────────────────────────────────────
    services.fluent-bit = {
      enable = true;
      settings = {
        pipeline = {
          inputs = [
            {
              name = "systemd";
              tag = "host-logs";
              db = "/var/lib/fluent-bit/journal.db"; # Persists cursor position
              read_from_tail = true;
              strip_underscores = true;
            }
          ];
          filters = [
            {
              name = "modify";
              match = "host-logs";
              rename = "SYSTEMD_UNIT job";
            }
            {
              name = "modify";
              match = "host-logs";
              condition = "Key_does_not_exist job";
              add = "job systemd-journal";
            }
          ];
          outputs = [
            {
              name = "loki";
              match = "host-logs";
              host = lokiHost;
              port = 3100;
              labels = "host=${config.networking.hostName}";
              label_keys = "$job";
            }
          ];
        };
      };
    };
    systemd.services.fluent-bit.serviceConfig = {
      StateDirectory = "fluent-bit";
    };
  };
}
