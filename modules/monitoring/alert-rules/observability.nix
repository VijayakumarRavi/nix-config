{
  groups = [
    {
      name = "missing-observability-alerts";
      rules = [
        {
          alert = "PrometheusTargetScrapeFailed";
          expr = "up{job!=\"node\", job!=\"fail2ban\"} == 0";
          for = "5m";
          labels.severity = "warning";
          annotations = {
            summary = "Prometheus target scrape failed: {{ $labels.job }} on {{ $labels.instance }}";
            description = "The Prometheus scraper is unable to scrape metrics from job {{ $labels.job }} on target {{ $labels.instance }} for over 5 minutes.";
            remediation = "Check if the exporter service (e.g. systemd-exporter, postgres-exporter, restic-exporter) is running on the host and reachable over firewall/wireguard.";
          };
        }
        {
          alert = "HostUnexpectedReboot";
          expr = "time() - node_boot_time_seconds < 600";
          for = "0m";
          labels.severity = "warning";
          annotations = {
            summary = "Host rebooted recently: {{ $labels.instance }}";
            description = "Host {{ $labels.instance }} has rebooted within the last 10 minutes (uptime is {{ printf \"%.0f\" $value }} seconds).";
            remediation = "Verify if the reboot was planned (system update / maintenance) or caused by a kernel crash or hardware issue. Check `journalctl -b -1 -e`.";
          };
        }
        {
          alert = "SystemdServiceFlapping";
          expr = "changes(node_systemd_unit_state{state=\"active\"}[15m]) > 3";
          for = "5m";
          labels.severity = "warning";
          annotations = {
            summary = "Systemd service flapping: {{ $labels.name }} on {{ $labels.instance }}";
            description = "The systemd unit {{ $labels.name }} on {{ $labels.instance }} has changed active state more than 3 times in the last 15 minutes.";
            remediation = "Inspect unit logs using `journalctl -u {{ $labels.name }}` to identify why the service is crashing and restarting continuously.";
          };
        }
        {
          alert = "LokiIngestionErrors";
          expr = "sum(rate(loki_request_duration_seconds_count{status=~\"5..\"}[5m])) > 0";
          for = "5m";
          labels.severity = "warning";
          annotations = {
            summary = "Loki experiencing HTTP 5xx errors";
            description = "Loki is returning 5xx server errors at rate {{ printf \"%.4f\" $value }}/s. Log ingestion or query failures may be occurring.";
            remediation = "Check Loki logs on Zoro using `journalctl -u loki` and verify storage backend and memory health.";
          };
        }
      ];
    }
  ];
}
