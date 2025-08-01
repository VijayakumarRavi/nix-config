{
  lib,
  pkgs,
  hostname,
  config,
  inputs,
  variables,
  ...
}: {
  imports = [inputs.sops-nix.nixosModules.sops];

  # Ensure a clean & sparkling /tmp on fresh boots.
  boot.tmp.cleanOnBoot = true;

  # IP forwarding is required to use a Linux device as a Tailscale subnet router
  boot.kernel.sysctl = {
    "vm.swappiness" = 60;
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  # No mutable users by default i.e you're unable to add new users using useradd and groupadd
  users.mutableUsers = false;

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  sops = {
    defaultSopsFile = ../../secrets.yaml;
    validateSopsFiles = false;

    age = {
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };

    secrets = {
      kubetoken = {};
      userhashedPassword = {
        neededForUsers = true;
      };
      tailscale_authkey = {};
      github_oauth_token = {};
      zoro_hc_url = {};
      usopp_hc_url = {};
      chopper_hc_url = {};
      "dnsproxy.yaml" = {
        restartUnits = ["dnsproxy.service"];
      };
      "keepalived_${hostname}.conf" = {
        restartUnits = ["keepalived.service"];
      };
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

  # Enable networking
  networking = {
    # Hostname
    hostName = hostname;
    # disable firewall
    firewall.enable = false;
    # Enabling WIFI
    wireless =
      if hostname == "nami" && hostname == "nixiso"
      then {
        enable = true;
        networks."vijay wifi".pskRaw = "9559e5edeed089f6c2834257d9f4de0cb442da4ddbee3a09e17707a9223f8958";
      }
      else {enable = false;};
    # Default nameserver to dnsproxy
    nameservers = ["10.0.0.10"];
    dhcpcd.extraConfig = "nohook resolv.conf";
    # Default gateway
    defaultGateway = {
      address = "10.0.0.1";
    };
    hosts = {};
  };

  # Set the etc host
  environment.etc."hosts".text = lib.mkForce ''
    127.0.0.1 localhost
    ::1 localhost
    ${variables.zoro_ip} zoro
    ${variables.usopp_ip} usopp
    ${variables.chopper_ip} chopper
  '';

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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${variables.username} = {
    isNormalUser = true;
    description = variables.user;
    extraGroups = [
      "networkmanager"
      "wheel"
      "disk"
      "power"
      "video"
      "docker"
    ];
    hashedPassword = "$6$b.0.YvdRoJj6j.WL$8epnXbbF5eplH348AMyDclGL2/CuaVX.6bWV5GY0zE1sVd1UtU7Svphp.m9DD5w0rSapXPftqJapsyVistkEJ1";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII8O84V4KrHZGAtdgY9vTYOGdH/BPcI846sM+MbCYuLX Mainkey"
    ];
  };

  # Disable sudo password
  security.sudo.wheelNeedsPassword = false;

  # Set Environment Variables
  environment.variables = {
    PATH = [
      "\${HOME}/.local/bin"
      "\${HOME}/.cargo/bin"
      "$/usr/local/bin"
    ];
    STARSHIP_CONFIG = "\${HOME}/.config/starship/starship.toml";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs = {
    mtr.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    nh = {
      enable = true;
      flake = "/home/${variables.username}/.nix-config";
      clean = {
        enable = true;
      };
    };
  };

  services = {
    # Enable the OpenSSH daemon.
    openssh.enable = true;

    fstrim.enable = true;

    pcscd.enable = true;

    # Configure keymap in X11
    xserver = {
      xkb.layout = "us";
      xkb.variant = "";
    };

    libinput.enable = true;

    # disable resolved and use dnsproxy
    resolved.enable = false;
  };

  system.activationScripts.diff = {
    supportsDryActivation = true;
    text = ''
      if [[ -e /run/current-system ]]; then
        echo "--- diff to current-system"
        ${pkgs.nvd}/bin/nvd --nix-bin-dir=${config.nix.package}/bin diff /run/current-system "$systemConfig"
        echo "---"
      fi
    '';
  };

  systemd = {
    # Given that systems are headless, emergency mode is useless.
    # We prefer the system to attempt to continue booting so
    # that we can hopefully still access it remotely.
    enableEmergencyMode = false;

    sleep.extraConfig = ''
      AllowSuspend=no
      AllowHibernation=no
    '';

    services.sshd.wantedBy = pkgs.lib.mkForce ["multi-user.target"];

    services.dnsproxy = {
      description = "Simple DNS proxy with DoH, DoT, DoQ and DNSCrypt support";
      after = ["network.target" "nss-lookup.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        ExecStart =
          "${pkgs.dnsproxy}/bin/dnsproxy"
          + " --config-path=${config.sops.secrets."dnsproxy.yaml".path}";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        Restart = "always";
        RestartSec = 10;
      };
    };
    services.keepalived = {
      description = "Keepalive Daemon For Dns Proxy";
      after = ["network.target" "network-online.target" "dnsproxy.service"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "forking";
        PIDFile = "/run/keepalived.pid";
        KillMode = "process";
        RuntimeDirectory = "keepalived";
        ExecStart =
          "${pkgs.keepalived}/bin/keepalived"
          + " -f ${config.sops.secrets."keepalived_${hostname}.conf".path}"
          + " -p /run/keepalived.pid";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        Restart = "always";
        RestartSec = "1s";
      };
    };
  };
}
