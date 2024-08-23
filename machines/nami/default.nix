{
  pkgs,
  inputs,
  variables,
  ...
}: {
  imports = [
    inputs.agenix.nixosModules.default
    inputs.raspberry-pi-nix.nixosModules.raspberry-pi
  ];

  nixpkgs.hostPlatform = "aarch64-linux";

  # bcm2711 for rpi 3, 3+, 4, zero 2 w
  # bcm2712 for rpi 5
  # See the docs at:
  # https://www.raspberrypi.com/documentation/computers/linux_kernel.html#native-build-configuration
  raspberry-pi-nix.board = "bcm2712";

  sdImage = {
    imageName = "NixPi.img";
    compressImage = true;
  };

  # Nix bin settings
  nix = {
    package = pkgs.nix;
    settings = {
      allowed-users = ["${variables.username}"];
      trusted-users = [
        "root"
        "${variables.username}"
      ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      warn-dirty = false;
      sandbox = false;
    };
  };

  # Reduce img size
  documentation.enable = false;

  time.timeZone = "Asia/Kolkata";

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

  # Console font size
  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-132n.psf.gz";
    packages = with pkgs; [terminus_font];
    keyMap = "us";
  };

  networking = {
    hostName = "nami";

    useDHCP = false;
    # disable firewall
    firewall.enable = false;
    # Enabling WIFI
    wireless = {
      enable = true;
      networks."vijay wifi".pskRaw = "9559e5edeed089f6c2834257d9f4de0cb442da4ddbee3a09e17707a9223f8958";
    };
    # Default nameservers
    nameservers = [
      "127.0.0.1"
      "45.90.28.215"
    ];
    # Default gateway
    defaultGateway = {
      address = "10.0.0.1";
    };
    interfaces = {
      wlan0.useDHCP = true;
      eth0.useDHCP = true;
    };
  };

  programs.zsh.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${variables.username} = {
    shell = pkgs.zsh;
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
  # List services that you want to enable
  services = {
    # Enable the OpenSSH daemon.
    openssh = {
      enable = true;
      settings.PermitRootLogin = "yes";
    };

    fstrim.enable = true;

    pcscd.enable = true;

    # Configure keymap in X11
    xserver = {
      xkb.layout = "us";
      xkb.variant = "";
    };
    libinput.enable = true;
  };
  systemd.services.sshd.wantedBy = pkgs.lib.mkForce ["multi-user.target"];

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    neovim
    tmux
    git
    gcc
    htop
  ];

  # Enable docker
  virtualisation.docker.enable = true;

  age.secrets = {
    id_ed25519 = {
      file = ../../secrets/id_ed25519;
      path = "/home/${variables.username}/.ssh/id_ed25519";
      owner = "${variables.username}";
      group = "users";
      mode = "600";
    };
    "id_ed25519.pub" = {
      file = ../../secrets/id_ed25519.pub;
      path = "/home/${variables.username}/.ssh/id_ed25519.pub";
      owner = "${variables.username}";
      group = "users";
    };
  };

  hardware = {
    bluetooth.enable = true;
    raspberry-pi = {
      config = {
        all = {
          base-dt-params = {
            # enable autoprobing of bluetooth driver
            # https://github.com/raspberrypi/linux/blob/c8c99191e1419062ac8b668956d19e788865912a/arch/arm/boot/dts/overlays/README#L222-L224
            krnbt = {
              enable = true;
              value = "on";
            };
          };
        };
      };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = variables.stateVersion; # Did you read the comment?
}
