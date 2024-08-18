{
  pkgs,
  meta,
  variables,
  ...
}: {
  imports = [
    ../common

    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ./scripts.nix
  ];

  nix = {
    gc = {
      automatic = true;
      options = "--delete-old";
    };
  };

  # Bootloader
  boot = {
    plymouth.enable = true;
    loader = {
      efi = {
        canTouchEfiVariables = true;
      };
      grub = {
        enable = true;
        efiSupport = true;
        devices = ["nodev"];
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
  };

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Enable networking
  networking = {
    # Hostname
    hostName = meta.hostname;
    # disable firewall
    firewall.enable = false;
    # Enabling WIFI
    wireless = {
      enable = true;
      networks."vijay wifi".pskRaw = "9559e5edeed089f6c2834257d9f4de0cb442da4ddbee3a09e17707a9223f8958";
    };
    # Default nameservers
    nameservers = [
      "10.0.0.2"
      "45.90.28.215"
    ];
    # Default gateway
    defaultGateway = {
      address = "10.0.0.1";
    };
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

  # Display manager stuff

  services = {
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --remember --time --asterisks --greeting \"Vanakkam da mapla 👻\" --cmd dwm";
          user = "${variables.username}";
        };
      };
    };
  };

  # Set Environment Variables
  environment.variables = {
    PATH = [
      "\${HOME}/.local/bin"
      "\${HOME}/.cargo/bin"
      "$/usr/local/bin"
    ];
    STARSHIP_CONFIG = "\${HOME}/.config/starship/starship.toml";

    # NIXOS_OZONE_WL = "1";  # vscode is not working if this is enabled
    NIXPKGS_ALLOW_UNFREE = "1";
    SCRIPTDIR = "\${HOME}/.local/share/scriptdeps";
    # XDG_CURRENT_DESKTOP = "Hyprland";
    # XDG_SESSION_TYPE = "wayland";
    # XDG_SESSION_DESKTOP = "Hyprland";
    # GDK_BACKEND = "wayland";
    # CLUTTER_BACKEND = "wayland";
    SDL_VIDEODRIVER = "x11";
    XCURSOR_SIZE = "24";
    XCURSOR_THEME = "Bibata-Modern-Ice";
    # QT_QPA_PLATFORM = "wayland";
    # QT_QPA_PLATFORMTHEME = "qt5ct";
    # QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    # QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    # MOZ_ENABLE_WAYLAND = "1";
  };

  # Sound options
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;

  # High quality BT calls
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # pipewire support
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-132n.psf.gz";
    packages = with pkgs; [terminus_font];
    keyMap = "us";
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

  age.secrets = {
    kubetoken = {
      file = ../../secrets/kubetoken;
    };
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

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs = {
    mtr.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  # List services that you want to enable:
  services = {
    # Enable the OpenSSH daemon.
    openssh.enable = true;

    fstrim.enable = true;

    pcscd.enable = true;

    # Configure keymap in X11
    xserver = {
      xkb.layout = "us";
      xkb.variant = "";
      /*
        windowManager.dwm = {
        enable =true;
      };
      */
    };

    libinput.enable = true;
  };
  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    sbctl
    git
    htop
    tmux

    libvirt
    swww
    polkit_gnome
    grim
    slurp
    lm_sensors
    unzip
    unrar
    file-roller
    libnotify
    swaynotificationcenter
    tofi
    xfce.thunar
    imv
    killall
    v4l-utils
    # ueberzugpp
    xdg-utils

    vscode # code editor developed by Microsoft
    _1password-gui # Best password manager imo
    _1password # 1Password manager CLI
    wl-clipboard
    # Audio
    pavucontrol
    pulseaudio
    audacity
    # Fonts
    font-awesome
    symbola
    noto-fonts-color-emoji
    material-icons
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = variables.stateVersion; # Did you read the comment?
}
