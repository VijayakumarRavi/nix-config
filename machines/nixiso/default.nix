{ lib
, pkgs
, modulesPath
, username
, ...
}: {
  # ISO settings
  imports = [
    "${modulesPath}/profiles/minimal.nix"
    "${modulesPath}/installer/cd-dvd/installation-cd-base.nix"
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  isoImage = {
    edition = lib.mkForce "custom";
    isoName = lib.mkForce "NixOS.iso";
  };

  # Nix bin settings
  nix = {
    package = pkgs.nix;
    settings = {
      allowed-users = [ "${username}" ];
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
    packages = with pkgs; [ terminus_font ];
    keyMap = "us";
  };

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Networking settings
  networking = {
    useDHCP = true;
    wireless = {
      enable = true;
      networks."vijay wifi".pskRaw = "9559e5edeed089f6c2834257d9f4de0cb442da4ddbee3a09e17707a9223f8958";
    };
    # Default nameservers
    nameservers = [
      "10.0.0.2"
      "45.90.28.215"
    ];
  };
  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    neovim
    tmux
    git
    htop
    lm_sensors
    unzip
    killall
  ];

  # user account.
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "users"
      "wheel"
      "disk"
      "power"
      "video"
      "networkmanager"
    ];
    description = "Default user account";
    hashedPassword = "$6$b.0.YvdRoJj6j.WL$8epnXbbF5eplH348AMyDclGL2/CuaVX.6bWV5GY0zE1sVd1UtU7Svphp.m9DD5w0rSapXPftqJapsyVistkEJ1";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII8O84V4KrHZGAtdgY9vTYOGdH/BPcI846sM+MbCYuLX Mainkey"
    ];
  };

  # password-less sudo
  security.sudo.wheelNeedsPassword = false;

  # Enable ssh
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };
  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
