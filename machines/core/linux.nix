{
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
      choppar_hc_url = {};
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
      if hostname == "nami" && variables.hostname == "nixiso"
      then {
        enable = true;
        networks."vijay wifi".pskRaw = "9559e5edeed089f6c2834257d9f4de0cb442da4ddbee3a09e17707a9223f8958";
      }
      else {enable = false;};
    # Default nameservers
    nameservers = [
      "10.0.2.2"
      "10.0.0.2"
      "45.90.28.215"
    ];
    # Default gateway
    defaultGateway = {
      address = "10.0.0.1";
    };
  };

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
        dates = "*-*-* 03:00:00";
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
  systemd =
    if hostname != "nami"
    then {
      # Given that systems are headless, emergency mode is useless.
      # We prefer the system to attempt to continue booting so
      # that we can hopefully still access it remotely.
      enableEmergencyMode = false;

      # For more detail, see:
      #   https://0pointer.de/blog/projects/watchdog.html
      watchdog = {
        # systemd will send a signal to the hardware watchdog at half
        # the interval defined here, so every 10s.
        # If the hardware watchdog does not get a signal for 20s,
        # it will forcefully reboot the system.
        runtimeTime = "20s";
        # Forcefully reboot if the final stage of the reboot
        # hangs without progress for more than 30s.
        # For more info, see:
        #   https://utcc.utoronto.ca/~cks/space/blog/linux/SystemdShutdownWatchdog
        rebootTime = "30s";
      };

      sleep.extraConfig = ''
        AllowSuspend=no
        AllowHibernation=no
      '';

      services.sshd.wantedBy = pkgs.lib.mkForce ["multi-user.target"];
    }
    else {services.sshd.wantedBy = pkgs.lib.mkForce ["multi-user.target"];};
}
