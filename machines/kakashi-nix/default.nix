{
  pkgs,
  variables,
  ...
}: {
  imports = [
    ../common
    ../common/linux.nix

    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ./scripts.nix
  ];

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

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    nh
    sbctl

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
