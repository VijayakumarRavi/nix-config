{ pkgs, ... }: {

  # qBittorrent
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
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
    };
  };

  # firewall rule
  networking.firewall = {
    allowedTCPPorts = [ 8080 8000 6881 ];
    allowedUDPPorts = [ 8080 8000 6881 ];
  };
}
