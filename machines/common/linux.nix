{
  pkgs,
  meta,
  config,
  variables,
  ...
}: {
  # Ensure a clean & sparkling /tmp on fresh boots.
  boot.tmp.cleanOnBoot = true;

  # No mutable users by default i.e you're unable to add new users using useradd and groupadd
  users.mutableUsers = false;

  nix = {
    gc = {
      automatic = true;
      options = "--delete-old";
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
    FLAKE = "/home/${variables.username}/.nix-config";
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

  systemd.services.sshd.wantedBy = pkgs.lib.mkForce ["multi-user.target"];

  age.secrets = {
    kubetoken = {file = ../../secrets/kubetoken;};
    tailauthKeyFile = {file = ../../secrets/tailauthKeyFile;};
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
}
