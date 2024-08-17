{
  pkgs,
  inputs,
  modulesPath,
  user,
  username,
  ...
}: {
  imports = [
    #"${modulesPath}/profiles/minimal.nix"
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"

    inputs.agenix.nixosModules.default
  ];

  nixpkgs.hostPlatform = "aarch64-linux";

  # Nix bin settings
  nix = {
    package = pkgs.nix;
    settings = {
      allowed-users = ["${username}"];
      trusted-users = [
        "root"
        "${username}"
      ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
    };
  };

  # Reduce img size
  documentation.enable = false;

  # Console font size
  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-132n.psf.gz";
    packages = with pkgs; [terminus_font];
    keyMap = "us";
  };

  sdImage = {
    imageName = "NixPi.img";
    compressImage = true;
  };

  time.timeZone = "Asia/Kolkata";

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

  # Enable ssh
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };
  systemd.services.sshd.wantedBy = pkgs.lib.mkForce ["multi-user.target"];

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    neovim
    tmux
    git
    htop
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    description = user;
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

  virtualisation.docker.enable = true;

  age.secrets = {
    id_ed25519 = {
      file = ../../secrets/id_ed25519;
      path = "/home/${username}/.ssh/id_ed25519";
      owner = "${username}";
      group = "users";
      mode = "600";
    };
    "id_ed25519.pub" = {
      file = ../../secrets/id_ed25519.pub;
      path = "/home/${username}/.ssh/id_ed25519.pub";
      owner = "${username}";
      group = "users";
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
