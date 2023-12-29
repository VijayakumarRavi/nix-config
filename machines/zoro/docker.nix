{ pkgs, ... }:{

# Enable docker
virtualisation.docker = {
  enable = true;
  # autoPrune.enable = true; # periodically prune Docker resources.
  # autoPrune.dates = "weekly";
  rootless = {
    enable = true;
    setSocketVariable = true;
  };
};

# A
virtualisation.oci-containers = {
  backend = "docker";
  containers = {
    ariang = {
      image = "wahyd4/aria2-ui";
      ports = [ "8080:80" "8443:443" ];
      autoStart = true;
      environment = {
        PUID = "1000";
        PGID = "1000";
        ENABLE_AUTH = "true";
        RPC_SECRET = "Hello";
        ARIA2_SSL = "false";
        ARIA2_USER = "vijay";
        ARIA2_PWD = "vijay";
        CADDY_LOG_LEVEL = "ERROR";
      };
      # workdir = "/home/vijay/docker/ariang";
      volumes = [
        "ariang:/app"
        "ariang-date:/data"
      ];
    };
  };
};

systemd.timers."docker-ariang-fix" = {
  wantedBy = [ "sysinit.target" ];
  after = [ "docker-ariang.service" ];
  timerConfig = {
    OnBootSec = "2m";
    Unit = "docker-ariang-fix.service";
  };
};

systemd.services."docker-ariang-fix" = {
  description = "NFS permission fix for ariang container";
  script = ''
    set -eu
    ${pkgs.coreutils}/bin/chmod -Rv 777 var/lib/docker/volumes/
  '';
  serviceConfig = {
    Type = "oneshot";
    User = "root";
  };
};
}
