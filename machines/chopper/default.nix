{
  pkgs,
  config,
  ...
}: {
  imports = [
    ../kubenodes
  ];
  networking.interfaces = {
    eno1 = {
      ipv4.addresses = [
        {
          address = "10.0.1.103";
          prefixLength = 16;
        }
      ];
    };
  };
  systemd.services.nixos-upgrade = {
    serviceConfig = {
      ExecStartPre = "/bin/sh -c 'PING_URL=$(cat ${config.sops.secrets.chopper_hc_url.path}) && ${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 -o /dev/null $PING_URL/start'";
      ExecStartPost = "/bin/sh -c 'PING_URL=$(cat ${config.sops.secrets.chopper_hc_url.path}) && ${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 -o /dev/null $PING_URL'";
    };
  };
}
