{
  pkgs,
  lib,
  ...
}: {
  # Runtime
  virtualisation = {
    docker = {
      enable = true;
      autoPrune.enable = true;
    };

    oci-containers = {
      backend = "docker";
      # Containers
      containers = {
        "backrest" = {
          image = "garethgeorge/backrest";
          environment = {
            "BACKREST_CONFIG" = "/config/config.json";
            "BACKREST_DATA" = "/config/data";
            "TZ" = "Asia/Kolkata";
            "XDG_CACHE_HOME" = "/cache";
          };
          volumes = [
            "/home/vijay/docker/backrest/cache:/cache:rw"
            "/home/vijay/docker/backrest/config:/config:rw"
            "/home/vijay:/backup:rw"
            "/home/vijay/.config/rclone/rclone.conf:/root/.config/rclone/rclone.conf:ro"
            "/home/vijay/.ssh:/root/.ssh:rw"
          ];
          ports = [
            "9898:9898/tcp"
          ];
          log-driver = "journald";
          extraOptions = [
            "--cpus=0.7"
            "--hostname=nami"
            "--network-alias=backrest"
            "--network=nami_default"
          ];
        };

        "pihole-unbound" = {
          image = "vijaysrv/pihole-unbound:2024.03.2";
          environment = {
            "DNSMASQ_LISTENING" = "single";
            "DNSSEC" = "true";
            "FTLCONF_LOCAL_IPV4" = "10.0.0.2";
            "PGID" = "1000";
            "PIHOLE_DNS_" = "127.0.0.1#5335";
            "PUID" = "1000";
            "REV_SERVER" = "true";
            "REV_SERVER_CIDR" = "10.0.0.0/16";
            "REV_SERVER_DOMAIN" = "local";
            "REV_SERVER_TARGET" = "10.0.0.1";
            "TZ" = "Asia/Kolkata";
            "WEBPASSWORD" = "vijay";
          };
          volumes = [
            "/home/vijay/docker/pihole/dnsmasq:/etc/dnsmasq.d:rw"
            "/home/vijay/docker/pihole/pihole:/etc/pihole:rw"
            "/home/vijay/docker/pihole/unbound:/etc/unbound:rw"
          ];
          ports = [
            "80:80/tcp"
            "53:53/tcp"
            "53:53/udp"
          ];
          log-driver = "journald";
          extraOptions = [
            "--dns=127.0.0.1"
            "--hostname=nami"
            "--network-alias=pihole"
            "--network=nami_default"
          ];
        };

        "watchtower" = {
          image = "containrrr/watchtower";
          environment = {
            "TZ" = "Asia/Kolkata";
            "WATCHTOWER_CLEANUP" = "true";
            "WATCHTOWER_INCLUDE_RESTARTING" = "true";
            "WATCHTOWER_INCLUDE_STOPPED" = "true";
            "WATCHTOWER_NOTIFICATION_REPORT" = "true";
            "WATCHTOWER_NOTIFICATION_URL" = "generic://notifiarr.com/api/v1/notification/watchtower/b1736dfe-8fd1-46de-b44d-b6d1ea641ede?template=json&server=Nami";
            "WATCHTOWER_NO_STARTUP_MESSAGE" = "true";
            "WATCHTOWER_REMOVE_VOLUMES" = "true";
            "WATCHTOWER_REVIVE_STOPPED" = "true";
            "WATCHTOWER_ROLLING_RESTART" = "true";
            "WATCHTOWER_SCHEDULE" = "0 2 * * *";
          };
          volumes = [
            "/var/run/docker.sock:/var/run/docker.sock:rw"
          ];
          log-driver = "journald";
          extraOptions = [
            "--hostname=nami"
            "--network-alias=watchtower"
            "--network=nami_default"
          ];
        };
      };
    };
  };

  systemd.services = {
    "docker-backrest" = {
      serviceConfig = {
        Restart = lib.mkOverride 500 "always";
      };
      after = [
        "docker-network-nami_default.service"
      ];
      requires = [
        "docker-network-nami_default.service"
      ];
      partOf = [
        "docker-compose-nami-root.target"
      ];
      wantedBy = [
        "docker-compose-nami-root.target"
      ];
    };

    "docker-pihole-unbound" = {
      serviceConfig = {
        Restart = lib.mkOverride 500 "always";
      };
      after = [
        "docker-network-nami_default.service"
      ];
      requires = [
        "docker-network-nami_default.service"
      ];
      partOf = [
        "docker-compose-nami-root.target"
      ];
      wantedBy = [
        "docker-compose-nami-root.target"
      ];
    };

    "docker-watchtower" = {
      serviceConfig = {
        Restart = lib.mkOverride 500 "always";
      };
      after = [
        "docker-network-nami_default.service"
      ];
      requires = [
        "docker-network-nami_default.service"
      ];
      partOf = [
        "docker-compose-nami-root.target"
      ];
      wantedBy = [
        "docker-compose-nami-root.target"
      ];
    };

    # Networks
    "docker-network-nami_default" = {
      path = [pkgs.docker];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStop = "docker network rm -f nami_default";
      };
      script = ''
        docker network inspect nami_default || docker network create nami_default
      '';
      partOf = ["docker-compose-nami-root.target"];
      wantedBy = ["docker-compose-nami-root.target"];
    };
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-nami-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = ["multi-user.target"];
  };
}
