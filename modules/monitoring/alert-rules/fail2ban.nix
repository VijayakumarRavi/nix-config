{
  groups = [
    {
      name = "fail2ban-alerts";
      rules = [
        {
          alert = "Fail2banDown";
          expr = "fail2ban_up == 0";
          for = "2m";
          labels.severity = "critical";
          annotations = {
            summary = "fail2ban down on {{ $labels.instance }}";
            description = "The fail2ban-client/service on {{ $labels.instance }} is down or not running. Intrusion prevention is inactive.";
            remediation = "SSH into the host and run `systemctl status fail2ban`. Check logs with `journalctl -u fail2ban`.";
          };
        }
        {
          alert = "Fail2banHighBanRate";
          expr = "increase(fail2ban_banned_total[15m]) > 10";
          for = "5m";
          labels.severity = "warning";
          annotations = {
            summary = "High authentication ban rate: {{ $labels.jail }} on {{ $labels.instance }}";
            description = "More than 10 IPs have been banned in the last 15 minutes in jail {{ $labels.jail }} on {{ $labels.instance }}. Potential brute-force attack in progress.";
            remediation = "Examine authentication logs using `journalctl -u sshd` or Nginx logs depending on the jail. Check currently banned IPs with `fail2ban-client status {{ $labels.jail }}`.";
          };
        }
      ];
    }
  ];
}
