{ ... }: {

  # Nginx proxy manager
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      proxy = {
        image = "jc21/nginx-proxy-manager:latest";
        ports = [ "80:80" "443:443" "81:81" ];
        autoStart = true;
        environment = {
          PUID = "1000";
          PGID = "1000";
          TZ = "Asia/Kolkata";
        };
        volumes = [
          "/docker/config/proxy/data:/data"
          "/docker/config/proxy/letsencrypt:/etc/letsencrypt"
        ];
      };
      watchtower = {
        image = "ghcr.io/containrrr/watchtower:latest";
        autoStart = true;
        volumes = [ "/var/run/docker.sock:/var/run/docker.sock" ];
        environment = {
          TZ = "Asia/Kolkata";
          WATCHTOWER_CLEANUP = "true";
          WATCHTOWER_SCHEDULE = "0 2 * * *";
          WATCHTOWER_REMOVE_VOLUMES = "true";
          WATCHTOWER_REVIVE_STOPPED = "true";
          WATCHTOWER_INCLUDE_STOPPED = "true";
          WATCHTOWER_ROLLING_RESTART = "true";
          WATCHTOWER_NO_STARTUP_MESSAGE = "true";
          WATCHTOWER_INCLUDE_RESTARTING = "true";
          WATCHTOWER_NOTIFICATION_URL =
            "discord://NMxnsSgx1ENy-OorcZET6C5oe_dFd-uS7a8kHMDe2Fyx6Fqe9CO_hv9KcbrPLuA1KJFZ@1092785786723782656";
        };
      };
    };
  };

  # firewall rule
  networking.firewall = {
    allowedTCPPorts = [ 80 81 443 ];
    allowedUDPPorts = [ 80 81 443 ];
  };
}
