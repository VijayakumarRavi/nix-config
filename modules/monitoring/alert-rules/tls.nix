{
  groups = [
    {
      name = "tls-alerts";
      rules = [
        {
          alert = "TLSCertExpiry30d";
          expr = "probe_ssl_earliest_cert_expiry - time() < 30 * 24 * 3600";
          for = "1h";
          labels.severity = "warning";
          annotations = {
            summary = "TLS certificate expiring in < 30 days: {{ $labels.instance }}";
            description = "The TLS certificate for {{ $labels.instance }} expires in {{ printf \"%.2f\" $value }} days (less than 30 days).";
            remediation = "Verify that the ACME renewal client (certbot/lego) is running and check its logs. Wildcard certificates should auto-renew.";
          };
        }
        {
          alert = "TLSCertExpiry7d";
          expr = "probe_ssl_earliest_cert_expiry - time() < 7 * 24 * 3600";
          for = "1h";
          labels.severity = "warning";
          annotations = {
            summary = "TLS certificate expiring in < 7 days: {{ $labels.instance }}";
            description = "The TLS certificate for {{ $labels.instance }} expires in {{ printf \"%.2f\" $value }} days (less than 7 days).";
            remediation = "Renew immediately. Check why Let's Encrypt / ACME automatic renewal is failing.";
          };
        }
        {
          alert = "TLSCertExpiry1d";
          expr = "probe_ssl_earliest_cert_expiry - time() < 1 * 24 * 3600";
          for = "10m";
          labels.severity = "critical";
          annotations = {
            summary = "TLS certificate expiring in < 24 hours: {{ $labels.instance }}";
            description = "The TLS certificate for {{ $labels.instance }} is about to expire in {{ printf \"%.2f\" $value }} hours! Action required.";
            remediation = "Urgent. Manually trigger ACME certificate renewal with `systemctl start acme-vjlab.dev.service` or equivalent. Check DNS/Cloudflare token.";
          };
        }
      ];
    }
  ];
}
