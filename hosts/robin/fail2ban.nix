_: {
  # Enable fail2ban Intrusion Prevention System
  services.fail2ban = {
    enable = true;
    maxretry = 5;
    ignoreIP = [
      "127.0.0.0/8"
      "10.0.0.0/8"
      "192.168.0.0/16"
      "172.16.0.0/12"
      "ddns.vjlab.dev"
    ];
    bantime = "24h"; # Ban IPs for 24 hours
    bantime-increment = {
      enable = true; # Increment ban time for repeat offenders
      formula = "banTime * 1.5";
      maxtime = "168h"; # Do not ban for more than 1 week
      overalljails = true; # Calculate increment across all jails
    };

    jails = {
      # SSH is enabled by default, but we override the port and backend
      sshd.settings = {
        enabled = true;
        port = "2222";
        filter = "sshd";
        logpath = "/var/log/auth.log";
        backend = "systemd";
      };

      # Nginx HTTP Auth failures (e.g. 401 Unauthorized/403 Forbidden)
      nginx-http-auth.settings = {
        enabled = true;
        filter = "nginx-http-auth";
        port = "http,https";
        logpath = "/var/log/nginx/error.log";
        backend = "systemd";
      };

      # Block bots and malicious scanners looking for vulnerabilities
      nginx-botsearch.settings = {
        enabled = true;
        filter = "nginx-botsearch";
        port = "http,https";
        logpath = "/var/log/nginx/error.log";
        backend = "systemd";
      };
    };
  };
}
