{ pkgs, ... }: {

  imports = [ ./media.nix ./general.nix ];

  # Enable docker
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true; # periodically prune Docker resources.
      flags = [ "--force" "--all" ];
      dates = "daily";
    };
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  # Fix container volumes permissions
  systemd.timers."docker-permission-fix" = {
    wantedBy = [ "sysinit.target" ];
    before = [ "docker.service" ];
    timerConfig = {
      OnBootSec = "2m";
      OnUnitActiveSec = "1h";
      Unit = "docker-permission-fix.service";
    };
  };

  systemd.services."docker-permission-fix" = {
    description = "NFS & Jellyfin permission fix for ariang container";
    script = ''
      set -eu
      ${pkgs.coreutils}/bin/chmod -Rv 777 /docker/download
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

}
