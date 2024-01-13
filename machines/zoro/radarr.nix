{ pkgs, ... }: {

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {

      # Radarr for movies
      radarr = {
        image = "lscr.io/linuxserver/radarr:latest";
        ports = [ "7878:7878" ];
        autoStart = true;
        environment = {
          PUID = "1000";
          PGID = "1000";
          TZ = "Asia/Kolkata";
        };
        volumes = [ "radarr:/config" "ariang-data:/movies" ];
      };

      # Sonarr for tv shows
      sonarr = {
        image = "lscr.io/linuxserver/sonarr:latest";
        ports = [ "8989:8989" ];
        autoStart = true;
        environment = {
          PUID = "1000";
          PGID = "1000";
          TZ = "Asia/Kolkata";
        };
        volumes = [ "sonarr:/config" "ariang-data:/tv" ];
      };

      # Jackett
      jackett = {
        image = "lscr.io/linuxserver/jackett:latest";
        ports = [ "9117:9117" ];
        autoStart = true;
        environment = {
          PUID = "1000";
          PGID = "1000";
          TZ = "Asia/Kolkata";
        };
        volumes = [ "jackett:/config" ];
      };
    };
  };

  # firewall rule to allow Radarr
  networking.firewall = {
    allowedTCPPorts = [ 7878 9117 8989 ];
    allowedUDPPorts = [ 7878 9117 8989 ];
  };

  systemd.timers."docker-radarr-volume-init" = {
    wantedBy = [ "sysinit.target" ];
    after = [ "docker.service" ];
    before = [
      "docker-radarr.service"
      "docker-sonarr.service"
      "docker-jackett.service"
    ];
    timerConfig = {
      OnBootSec = "2m";
      Unit = "docker-radarr-volume-init.service";
    };
  };

  systemd.services."docker-radarr-volume-init" = {
    description = "Create the docker volume for radarr.";
    before = [ "docker-radarr.service" ];
    serviceConfig.Type = "oneshot";
    serviceConfig.User = "root";
    script = ''
      # Put a true at the end to prevent getting non-zero return code, which will crash the whole service.
      checkradarr=$( ${pkgs.docker}/bin/docker volume ls | ${pkgs.gnugrep}/bin/grep  -E '(^|\s)radarr($|\s)' || true)
      checkjackett=$( ${pkgs.docker}/bin/docker volume ls | ${pkgs.gnugrep}/bin/grep  -E '(^|\s)jackett($|\s)' || true)
      checksonarr=$( ${pkgs.docker}/bin/docker volume ls | ${pkgs.gnugrep}/bin/grep -E '(^|\s)sonarr($|\s)' || true)
      if [ -z "$checkradarr" ]; then
        ${pkgs.docker}/bin/docker volume create radarr
      else
          echo "radarr volume already exists in docker"
      fi
      if [ -z "$checkjackett" ]; then
        ${pkgs.docker}/bin/docker volume create jackett
      else
          echo "jackett volume already exists in docker"
      fi
      if [ -z "$checksonarr" ]; then
        ${pkgs.docker}/bin/docker volume create sonarr
      else
          echo "sonarr volume already exists in docker"
      fi
    '';
  };

}
