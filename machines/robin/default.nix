{
  lib,
  pkgs,
  hostname,
  variables,
  modulesPath,
  ...
}: {
  # ISO settings
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")

    ../core

    # docker configuration
    ./docker.nix
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
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
      "fs.inotify.max_queued_events" = 524288;
      "fs.inotify.max_user_instances" = 16383;
      "fs.inotify.max_user_watches" = 524288;
    };
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
  # Nix bin settings
  nixpkgs.hostPlatform = "x86_64-linux";
  nix.settings.auto-optimise-store = true;

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
      allowedTCPPorts = [69];
      allowedUDPPorts = [69];
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
    extraGroups = [
      "users"
      "docker"
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
      PasswordAuthentication = false;
      AllowUsers = ["${variables.username}"];
      PermitRootLogin = "no";
    };
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
