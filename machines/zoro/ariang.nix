{ pkgs, ... }: {

  # Ariang
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
          ARIA2_SSL = "false";
          ARIA2_USER = "vijay";
          ARIA2_PWD = "Vijay@29oct";
          RPC_SECRET = "vijay";
          CADDY_LOG_LEVEL = "ERROR";
        };
        # workdir = "/home/vijay/docker/ariang";
        volumes = [ "ariang:/app" "ariang-data:/data" ];
      };
    };
  };

  # firewall rule to allow jellyfin
  networking.firewall = {
    allowedTCPPorts = [ 8080 ];
    allowedUDPPorts = [ 8080 ];
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

  systemd.timers."docker-ariang-volume-init" = {
    wantedBy = [ "sysinit.target" ];
    after = [ "docker.service" ];
    before = [ "docker-ariang.service" ];
    timerConfig = {
      OnBootSec = "2m";
      Unit = "docker-ariang-volume-init.service";
    };
  };

  systemd.services."docker-ariang-volume-init" = {
    description = "Create the docker volume for ariang.";
    before = [ "docker-ariang.service" ];
    serviceConfig.Type = "oneshot";
    serviceConfig.User = "root";
    script = ''
      # Put a true at the end to prevent getting non-zero return code, which will crash the whole service.
      checkariang=$( ${pkgs.docker}/bin/docker volume ls | ${pkgs.gnugrep}/bin/grep  -E '(^|\s)ariang($|\s)' || true)
      checkariangdata=$( ${pkgs.docker}/bin/docker volume ls | ${pkgs.gnugrep}/bin/grep -E '(^|\s)ariang-data($|\s)' || true)
      if [ -z "$checkariang" ]; then
        ${pkgs.docker}/bin/docker volume create ariang
      else
          echo "ariang volume already exists in docker"
      fi
      if [ -z "$checkariangdata" ]; then
        ${pkgs.docker}/bin/docker volume create ariang-data
      else
          echo "ariang-data volume already exists in docker"
      fi
    '';
  };
}
