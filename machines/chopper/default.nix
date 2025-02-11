{
  pkgs,
  config,
  variables,
  ...
}: {
  imports = [
    ../kubenodes
  ];
  networking.interfaces = {
    eth0 = {
      ipv4.addresses = [
        {
          address = "${variables.chopper_ip}";
          prefixLength = 16;
        }
      ];
    };
  };

  system.autoUpgrade.dates = "Sun *-*-* 04:00:00";
  programs.nh.clean.dates = "Sun *-*-* 03:00:00";

  systemd.services.nixos-upgrade = {
    serviceConfig = {
      ExecStartPre = "/bin/sh -c 'PING_URL=$(cat ${config.sops.secrets.chopper_hc_url.path}) && ${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 -o /dev/null $PING_URL/start'";
      ExecStartPost = "/bin/sh -c 'PING_URL=$(cat ${config.sops.secrets.chopper_hc_url.path}) && ${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 -o /dev/null $PING_URL'";
    };
  };
}
