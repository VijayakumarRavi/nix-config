{
  groups = [
    {
      name = "nginx-alerts";
      rules = [
        {
          alert = "NginxDown";
          expr = "nginx_up == 0";
          for = "1m";
          labels.severity = "critical";
          annotations = {
            summary = "Nginx down on {{ $labels.instance }}";
            description = "Nginx service is unreachable or down on host {{ $labels.instance }}.";
            remediation = "SSH into the host and run `systemctl status nginx`. Check Nginx configuration using `nginx -t` and inspect error logs.";
          };
        }
        {
          alert = "NginxHighErrorRate";
          # sum(rate(nginx_connections_accepted[5m])) or similar can be used for error rate.
          # The nginx-exporter publishes `nginx_connections_active` and request rates if stub_status exposes them.
          # Since stub_status is basic, it exposes active connections, accepted/handled, and requests.
          # If stub_status doesn't provide status codes, we can only monitor nginx availability, connections, and request rate.
          # Let's rely on blackbox-exporter (which checks http status codes) for 5xx/error rates,
          # and use nginx-exporter for connection counts and worker traffic.
          expr = "nginx_connections_active > 500";
          for = "5m";
          labels.severity = "warning";
          annotations = {
            summary = "Nginx high active connection count on {{ $labels.instance }}";
            description = "Nginx has {{ $value }} active connections on host {{ $labels.instance }}.";
            remediation = "Check Nginx traffic patterns. Use `netstat` or `ss` to inspect connections. Determine if there is a spike in load or DDoS attack.";
          };
        }
      ];
    }
  ];
}
