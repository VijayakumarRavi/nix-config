{
  groups = [
    {
      name = "self-monitoring-alerts";
      rules = [
        {
          alert = "AlertmanagerDown";
          expr = "up{job=\"alertmanager\"} == 0";
          for = "2m";
          labels.severity = "critical";
          annotations = {
            summary = "Alertmanager down on {{ $labels.instance }}";
            description = "Prometheus is unable to reach Alertmanager at {{ $labels.instance }}. Alerts cannot be dispatched.";
            remediation = "SSH into Zoro and run `systemctl status alertmanager`. Inspect logs with `journalctl -u alertmanager`.";
          };
        }
        {
          alert = "LokiDown";
          expr = "up{job=\"loki\"} == 0";
          for = "2m";
          labels.severity = "critical";
          annotations = {
            summary = "Loki down on {{ $labels.instance }}";
            description = "Loki log aggregation daemon is unreachable on {{ $labels.instance }}. Promtail logs will buffer.";
            remediation = "Check the Loki service status on Zoro with `systemctl status loki`. Inspect service logs and disk usage.";
          };
        }
        {
          alert = "GrafanaDown";
          expr = "up{job=\"grafana\"} == 0";
          for = "5m";
          labels.severity = "warning";
          annotations = {
            summary = "Grafana down on {{ $labels.instance }}";
            description = "Grafana service is unreachable on {{ $labels.instance }}. Dashboards are inaccessible.";
            remediation = "Check Grafana service status on Zoro with `systemctl status grafana`.";
          };
        }
        {
          alert = "WireGuardTunnelDown";
          # If all Robin exporters are down, the WireGuard tunnel itself is likely down.
          # We check if node-exporter is down on Robin while node-exporter on Zoro is UP.
          # This avoids firing WireGuardTunnelDown if the Zoro monitoring host itself is down
          # (in which case Prometheus wouldn't run anyway, or it's a global network issue).
          expr = "up{instance=\"robin\", job=\"node\"} == 0 and up{instance=\"zoro\", job=\"node\"} == 1";
          for = "2m";
          labels.severity = "critical";
          annotations = {
            summary = "WireGuard monitoring tunnel down";
            description = "Prometheus on Zoro is unable to scrape any exporters on Robin, while Zoro local scraping works. The WireGuard monitor tunnel is down.";
            remediation = "Check WireGuard interface status on both hosts with `wg show`. Restart `wireguard-wg-monitor.service` on Robin and Zoro.";
          };
        }
        {
          alert = "PrometheusTSDBCompactionFailed";
          expr = "prometheus_tsdb_compaction_cancels_total > 0";
          for = "0m";
          labels.severity = "warning";
          annotations = {
            summary = "Prometheus TSDB compaction failed on {{ $labels.instance }}";
            description = "Prometheus is experiencing compaction failures on disk. This can cause storage issues.";
            remediation = "Check Zoro disk health and free space. Inspect Prometheus logs for corruption errors.";
          };
        }
        {
          alert = "PrometheusRuleEvaluationFailures";
          expr = "rate(prometheus_rule_evaluation_failures_total[5m]) > 0";
          for = "5m";
          labels.severity = "warning";
          annotations = {
            summary = "Prometheus rule evaluation failing on {{ $labels.instance }}";
            description = "Prometheus is failing to evaluate alert rules on {{ $labels.instance }}. Alerts may be delayed.";
            remediation = "Check the logs of prometheus.service on Zoro. Verify syntax of rules or metrics availability.";
          };
        }
      ];
    }
  ];
}
