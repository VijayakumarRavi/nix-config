{
  groups = [
    {
      name = "application-alerts";
      rules = [
        {
          alert = "AppDown";
          expr = "probe_success{job=~\"blackbox-.*\"} == 0";
          for = "2m";
          labels.severity = "critical";
          annotations = {
            summary = "Application down: {{ $labels.instance }}";
            description = "The application endpoint {{ $labels.instance }} failed its health check probe (type: {{ $labels.probe_type }}).";
            remediation = "Determine if the probe is internal or external. Check host service status (e.g. pocket-id, lldap, ente) on Robin. Check Nginx proxy routing and certificates.";
          };
        }
        {
          alert = "AppHighLatency";
          expr = "probe_duration_seconds{job=~\"blackbox-.*\"} > 2";
          for = "10m";
          labels.severity = "warning";
          annotations = {
            summary = "Slow application response: {{ $labels.instance }}";
            description = "Health probe duration for {{ $labels.instance }} is {{ printf \"%.2f\" $value }} seconds (exceeds 2s limit) for the last 10 minutes.";
            remediation = "Inspect application load, database connections, and host CPU/RAM resources. Look for slow SQL queries or network congestion.";
          };
        }
      ];
    }
  ];
}
