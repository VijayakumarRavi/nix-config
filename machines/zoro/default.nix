{
  pkgs,
  config,
  ...
}: {
  imports = [
    ../kubenodes
  ];
  networking.interfaces = {
    eth0 = {
      ipv4.addresses = [
        {
          address = "10.0.1.101";
          prefixLength = 16;
        }
      ];
    };
  };

  system.autoUpgrade.dates = "Fri *-*-* 04:00:00";

  systemd.services.nixos-upgrade = {
    serviceConfig = {
      ExecStartPre = "/bin/sh -c 'PING_URL=$(cat ${config.sops.secrets.zoro_hc_url.path}) && ${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 -o /dev/null $PING_URL/start'";
      ExecStartPost = "/bin/sh -c 'PING_URL=$(cat ${config.sops.secrets.zoro_hc_url.path}) && ${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 -o /dev/null $PING_URL'";
    };
  };
}
