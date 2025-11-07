{
  lib,
  pkgs,
  config,
  hostname,
  variables,
  modulesPath,
  ...
}: let
  domain = "minio.franky.vjlab.dev";
in {
  # ISO settings
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")

    ../core

    # Sops module
    # inputs.sops-nix.nixosModules.sops

    # Declarative disk partitioning config
    ./disk-config.nix
  ];

  boot = {
    initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_blk"];
    initrd.kernelModules = [];
    kernelModules = ["br_netfilter"];
    extraModulePackages = [];
    # Ensure a clean & sparkling /tmp on fresh boots.
    tmp.cleanOnBoot = true;
    # IP forwarding is required to use a Linux device as a Tailscale subnet router
    kernel.sysctl = {
      "vm.swappiness" = 60;
      "kernel.dmesg_restrict" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
      "fs.inotify.max_queued_events" = 524288;
      "fs.inotify.max_user_instances" = 16383;
      "fs.inotify.max_user_watches" = 524288;
      "net.ipv4.tcp_syncookies" = 1;
      "net.ipv4.conf.all.rp_filter" = 1;
      "net.ipv4.conf.default.rp_filter" = 1;
      "net.ipv4.ip_forward" = 0;
    };
    loader.grub = {
      enable = true;
      extraEntries = ''
        menuentry "System Reboot" {
          echo "System rebooting..."
          reboot
        }
        menuentry "System Poweroff" {
          echo "System shutting down..."
          halt
        }
      '';
    };
  };

  # Nix bin settings
  nixpkgs.hostPlatform = "x86_64-linux";
  nix.settings.auto-optimise-store = true;
  /*
  sops = {
    defaultSopsFile = ../../secrets.yaml;
    validateSopsFiles = false;

    age = {
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };

    secrets = {
      minio_root_user = {};
      minio_root_password = {};
      id_ed25519 = {
        owner = config.users.users.${variables.username}.name;
        inherit (config.users.users.${variables.username}) group;
        path = "/home/${variables.username}/.ssh/id_ed25519";
      };
      id_ed25519_pub = {
        owner = config.users.users.${variables.username}.name;
        inherit (config.users.users.${variables.username}) group;
        path = "/home/${variables.username}/.ssh/id_ed25519.pub";
      };
    };
  };
  */
  # Console font size
  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-132n.psf.gz";
    packages = with pkgs; [terminus_font];
    keyMap = "us";
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_IN";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENggT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  networking = {
    # Hostname
    hostName = hostname;
    useDHCP = lib.mkDefault true;
    nameservers = ["1.1.1.1"];

    firewall = {
      enable = true;
      allowedTCPPorts = [69 80 443];
      allowedUDPPorts = [69 80 443];
    };
  };

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    lm_sensors
    unzip
    killall
  ];

  # user account.
  users.users.${variables.username} = {
    isNormalUser = true;
    group = "${variables.username}";
    extraGroups = [
      "users"
      "wheel"
      "disk"
    ];
    description = "Default user account";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII8O84V4KrHZGAtdgY9vTYOGdH/BPcI846sM+MbCYuLX Mainkey"
    ];
  };

  # password-less sudo
  security.sudo.wheelNeedsPassword = false;

  services = {
    fstrim.enable = true;
    qemuGuest.enable = true;
  };

  # Enable ssh
  services.openssh = {
    enable = true;
    ports = [69];
    settings = {
      challengeResponseAuthentication = false;
      PasswordAuthentication = false;
      AllowUsers = ["${variables.username}"];
      PermitRootLogin = "no";
    };
    extraConfig = ''
      ClientAliveInterval 300
      ClientAliveCountMax 2
    '';
  };

  # Create a dedicated user for minio with minimal privileges
  users.groups.minio = {};
  users.users.minio = {
    isSystemUser = true;
    createHome = false;
    description = "MinIO service user";
    group = "minio";
  };
  # MinIO: run on localhost and expose via nginx reverse-proxy (TLS terminated by nginx)
  # Single-node MinIO for S3-API compatibility. Bind to loopback for safety.
  systemd.services.minio = {
    description = "MinIO object storage";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    serviceConfig = {
      User = "minio";
      Group = "minio";
      Restart = "on-failure";
      AmbientCapabilities = "CAP_NET_BIND_SERVICE";
      # keep private /tmp and other hardening flags
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      NoNewPrivileges = true;
    };
    environment = {
      MINIO_VOLUMES = "/var/lib/minio/data";
      MINIO_REGION = "us-east-1";
      MINIO_SERVER_URL = "http://${domain}";
      MINIO_BROWSER_REDIRECT_URL = "https://${domain}/minio/ui/";
      MINIO_COMPRESSION_ENABLE = "on";
      MINIO_CACHE_ENABLE = "on";
      MINIO_BROWSER = "on";
      # MINIO_ROOT_USER_FILE = "${config.sops.secrets."minio_root_user".path}";
      # MINIO_ROOT_PASSWORD_FILE = "${config.sops.secrets."minio_root_password".path}";
      # MINIO_PROMETHEUS_AUTH_TYPE = "public";
      # MINIO_PROMETHEUS_URL = "http://${domain}/minio/prometheus";
    };
    path = [pkgs.minio];
    script = ''
      mkdir -p /var/lib/minio/data
      chown -R minio:minio /var/lib/minio/data
      exec ${pkgs.minio}/bin/minio server --address 127.0.0.1:9000 --console-address 127.0.0.1:9001 ${config.systemd.services.minio.environment.MINIO_VOLUMES}
    '';
  };

  # nginx reverse-proxy in front of MinIO (TLS with ACME)
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    validateConfigFile = true;
    enableReload = true;

    virtualHosts = {
      "${domain}" = {
        forceSSL = true;
        enableACME = true;
        root = "/var/www/empty";
        extraConfig = ''
          ssl_protocols TLSv1.2 TLSv1.3;
          ssl_prefer_server_ciphers on;
          ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
        '';
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:9000"; # MinIO server
            proxyWebsockets = true;
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-Host $host;
              proxy_set_header X-Forwarded-Port $server_port;
            '';
          };
          "/minio/ui/" = {
            # route console under /minio/ to console port
            proxyPass = "http://127.0.0.1:9001/";
            proxyWebsockets = true;
            extraConfig = ''
              rewrite ^/minio/ui/(.*) /$1 break;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_http_version 1.1;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "upgrade";
            '';
          };
        };
      };
    };
  };

  # Let's Encrypt / ACME configuration
  security.acme = {
    acceptTerms = true;
    defaults.email = "${variables.useremail}";
    certs = {
      "${domain}" = {
        webroot = "/var/www/empty";
      };
    };
  };

  # Fail2ban to protect exposed services (ssh and nginx/minio login attempts)
  services.fail2ban = {
    enable = true;
    jails = {
      sshd = {enabled = true;};
      nginx-http-auth = {enabled = true;};
      # you can define a custom jail for MinIO by monitoring minio logs
    };
  };

  # Log rotation and basics
  /*
     services.logrotate = {
    enable = true;
    extraConfig = "compress";
  };
  */
  # Enable auditing for suspicious activity (auditd)
  security.auditd.enable = true;

  # Limit services running as root where possible
  systemd.services."nginx".serviceConfig = {
    DynamicUser = true;
    ProtectHome = true;
  };

  services.prometheus = {
    enable = true;
    exporters = {
      node.enable = true;
      nginx.enable = true;
    };
  };

  services.printing.enable = false;

  services.journald = {
    extraConfig = ''
      SystemMaxUse=200M
      RuntimeMaxUse=100M
    '';
  };

  systemd.services.sshd.wantedBy = pkgs.lib.mkForce ["multi-user.target"];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = variables.stateVersion; # Did you read the comment?
}
