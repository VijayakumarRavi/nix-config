_: {
  virtualisation.oci-containers.backend = "docker";

  networking.firewall.allowedTCPPorts = [25 80 110 143 443 465 587 993 995 4190 24957];
  networking.firewall.allowedUDPPorts = [25 80 110 143 443 465 587 993 995 4190 24957];

  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
    autoPrune.dates = "weekly";
    storageDriver = "btrfs";
    daemon.settings = {
      live-restore = true;
      data-root = "/opt/docker/.data_root";
      userland-proxy = false;
      dns = ["1.1.1.1" "9.9.9.9"];
      experimental = true;
      ipv6 = true;
      fixed-cidr-v6 = "fd00::/80";
      metrics-addr = "0.0.0.0:9323";
      log-driver = "json-file";
      log-opts.max-size = "10m";
      log-opts.max-file = "10";
    };
  };
}
