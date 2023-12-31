{ pkgs, inputs, config, ... }: {
  imports = [ inputs.sops-nix.nixosModules.sops ];
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";

  sops.age.keyFile = "/home/vijay/.config/sops/age/keys.txt";

  sops.secrets."containers/ariang/aria2_user" = { owner = "root"; };
  sops.secrets."containers/ariang/aria2_pass" = { owner = "root"; };
  sops.secrets."containers/ariang/rpc_secret" = { owner = "root"; };

  # Enable docker
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true; # periodically prune Docker resources.
    autoPrune.dates = "daily";
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
          ARIA2_SSL = "false";
          ARIA2_USER = builtins.readFile
            config.sops.secrets."containers/ariang/aria2_user".path;
          ARIA2_PWD = builtins.readFile
            config.sops.secrets."containers/ariang/aria2_pass".path;
          RPC_SECRET = builtins.readFile
            config.sops.secrets."containers/ariang/rpc_secret".path;
          CADDY_LOG_LEVEL = "ERROR";
        };
        # workdir = "/home/vijay/docker/ariang";
        volumes = [ "ariang:/app" "ariang-data:/data" ];
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
