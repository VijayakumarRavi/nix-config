{ pkgs, inputs, ... }:

{
  imports = [
    ../common

    # Include the results of the hardware scan.
    "${inputs.hw-config}/hardware-configuration.nix"
    # /etc/nixos/hardware-configuration.nix
  ];

  nix = {
    gc = {
      automatic = true;
      dates = "*-*-1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31 00:00:00";
      options = "--delete-old";
    };

  };

  #disable nix documentation
  documentation.enable = false;

  # Bootloader
  boot = {
    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    # Enable unlock disk encryption with ssh
    kernelParams = [ "ip=10.0.0.4::10.0.0.1:255.255.0.0:zoro::none" ];
    initrd = {
      availableKernelModules = [ "e1000e" ];
      systemd.users.root.shell = "/bin/cryptsetup-askpass";
      network.enable = true;
      network.ssh = {
        enable = true;
        port = 22;
        hostKeys = [ "/etc/ssh/ssh_host_ed25519_key" ];
        authorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII8O84V4KrHZGAtdgY9vTYOGdH/BPcI846sM+MbCYuLX Mainkey"
        ];
      };
    };
    # Emulate an arm64 machine for RPI
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  # Enable networking
  networking = {
    # Hostname
    hostName = "zoro";
    # Enabling WIFI
    wireless = {
      enable = true;
      interfaces = [ "wlo1" ];
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
      interface = "eno2";
    };
    # Static IP
    useDHCP = false;
    interfaces.eno2 = {
      ipv4.addresses = [
        {
          address = "10.0.0.4";
          prefixLength = 16;
        }
      ];
    };
    interfaces.wlo1 = {
      useDHCP = true;
    };
  };

  # Set your time zone.
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

  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-132n.psf.gz";
    packages = with pkgs; [ terminus_font ];
    keyMap = "us";
  };
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.vijay = {
    isNormalUser = true;
    description = "Vijayakumar Ravi";
    extraGroups = [
      "networkmanager"
      "wheel"
      "disk"
      "power"
      "video"
      "docker"
    ];
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
    NIXPKGS_ALLOW_UNFREE = "1";
    SCRIPTDIR = "\${HOME}/.local/share/scriptdeps";
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
    };

    libinput.enable = true;

    nfs.server = {
      enable = true;
      # fixed rpc.statd port; for firewall
      lockdPort = 4001;
      mountdPort = 4002;
      statdPort = 4000;
      exports = ''
        /mnt/share     *(rw,sync,wdelay,hide,no_subtree_check,fsid=0,sec=sys,insecure,no_root_squash,no_all_squash)
      '';
    };
  };

  networking.firewall.enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    sbctl
    lm_sensors
    unzip
    unrar
    killall
    # kubernetes
    cifs-utils
    nfs-utils
  ];

  fonts.packages = with pkgs; [
    (nerdfonts.override {
      fonts = [
        "JetBrainsMono"
        "Ubuntu"
      ];
    })
  ];

  services.k3s = {
    enable = true;
    role = "server";
    clusterInit = true;
    token = "TemjVK4KJqlT8FFO";
    extraFlags = toString [
      ''--write-kubeconfig-mode "0644"''
      "--cluster-init"
      "--disable servicelb"
      "--disable traefik"
      "--disable local-storage"
      # "--server https://zoro:6443"
    ];
  };

  services.openiscsi = {
    enable = true;
    name = "iqn.2016-04.com.open-iscsi:zoro";
  };

  # Fixes for longhorn
  systemd.tmpfiles.rules = [ "L+ /usr/local/bin - - - - /run/current-system/sw/bin/" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
