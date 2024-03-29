{ ... }: {
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      #qBittorrent downloader
      qbittorrent = {
        image = "ghcr.io/hotio/qbittorrent:latest";
        ports = [ "8000:8000" ];
        autoStart = true;
        environment = {
          PUID = "1000";
          PGID = "1000";
          TZ = "Asia/Kolkata";
          WEBUI_PORTS = "8000/tcp,8000/udp";
          UMASK = "002";
        };
        volumes = [
          "/docker/config/qbittorrent:/config"
          "/docker/download:/downloads"
        ];
      };

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
        volumes =
          [ "/docker/config/radarr:/config" "/docker/download/movies:/movies" ];
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
        volumes =
          [ "/docker/config/sonarr:/config" "/docker/download/shows:/tv" ];
      };

      # Lidarr
      lidarr = {
        image = "lscr.io/linuxserver/lidarr:latest";
        ports = [ "8686:8686" ];
        autoStart = true;
        environment = {
          PUID = "1000";
          PGID = "1000";
          TZ = "Asia/Kolkata";
        };
        volumes =
          [ "/docker/config/lidarr:/config" "/docker/download/music:/music" ];
      };

      # Prowlarr
      Prowlarr = {
        image = "lscr.io/linuxserver/prowlarr:latest";
        ports = [ "9696:9696" ];
        autoStart = true;
        environment = {
          PUID = "1000";
          PGID = "1000";
          TZ = "Asia/Kolkata";
        };
        volumes = [ "/docker/config/Prowlarr:/config" ];
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
        volumes = [ "/docker/config/jackett:/config" ];
      };
    };
  };

  # firewall rule
  networking.firewall = {
    allowedTCPPorts = [ 8000 7878 9117 8989 8686 9696 ];
    allowedUDPPorts = [ 8000 7878 9117 8989 8686 9696 ];
  };
}
