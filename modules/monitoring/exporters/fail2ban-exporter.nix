# fail2ban-exporter — fail2ban metrics via textfile collector
# No nixpkgs exporter exists. Uses a systemd timer to write metrics
# to the node-exporter textfile collector directory.
# Conditional: only enabled when services.monitoring.exporters.fail2ban.enable = true
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.monitoring;

  # Script to query fail2ban-client and write prometheus metrics
  fail2banCollector = pkgs.writeShellScript "fail2ban-collector" ''
    set -euo pipefail

    OUTPUT_FILE="/var/lib/node-exporter/textfile/fail2ban.prom"
    TMPFILE="$(mktemp)"

    # Check if fail2ban is running
    if ! ${pkgs.systemd}/bin/systemctl is-active --quiet fail2ban.service; then
      echo "fail2ban_up 0" > "$TMPFILE"
      chmod 0644 "$TMPFILE"
      mv "$TMPFILE" "$OUTPUT_FILE"
      exit 0
    fi

    echo "fail2ban_up 1" > "$TMPFILE"

    # Get list of jails
    jails=$(${pkgs.fail2ban}/bin/fail2ban-client status 2>/dev/null | grep "Jail list:" | sed 's/.*Jail list:\s*//' | tr ',' '\n' | sed 's/\s//g')

    for jail in $jails; do
      status=$(${pkgs.fail2ban}/bin/fail2ban-client status "$jail" 2>/dev/null || true)
      if [ -n "$status" ]; then
        banned=$(echo "$status" | grep "Currently banned:" | awk '{print $NF}')
        failed=$(echo "$status" | grep "Currently failed:" | awk '{print $NF}')
        total_banned=$(echo "$status" | grep "Total banned:" | awk '{print $NF}')
        total_failed=$(echo "$status" | grep "Total failed:" | awk '{print $NF}')

        echo "fail2ban_banned_current{jail=\"$jail\"} ''${banned:-0}" >> "$TMPFILE"
        echo "fail2ban_failed_current{jail=\"$jail\"} ''${failed:-0}" >> "$TMPFILE"
        echo "fail2ban_banned_total{jail=\"$jail\"} ''${total_banned:-0}" >> "$TMPFILE"
        echo "fail2ban_failed_total{jail=\"$jail\"} ''${total_failed:-0}" >> "$TMPFILE"
      fi
    done

    chmod 0644 "$TMPFILE"
    mv "$TMPFILE" "$OUTPUT_FILE"
  '';
in {
  config = lib.mkIf (cfg.enable && cfg.exporters.fail2ban.enable) {
    # ── Systemd timer to collect fail2ban metrics ─────────────────────
    systemd.services.fail2ban-textfile-collector = {
      description = "Collect fail2ban metrics for Prometheus textfile collector";
      path = with pkgs; [gnugrep gawk gnused coreutils];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${fail2banCollector}";
      };
    };

    systemd.timers.fail2ban-textfile-collector = {
      description = "Timer for fail2ban Prometheus textfile collector";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "1min";
        OnUnitActiveSec = "1min";
        Unit = "fail2ban-textfile-collector.service";
      };
    };
  };
}
