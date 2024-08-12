{ lib, pkgs, modulesPath, ... }: {
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

  # user account.
  users.users.vijay = {
    password = "vijay";
    isNormalUser = true;
    extraGroups = [
      "users"
      "wheel"
      "disk"
      "power"
      "video"
      "networkmanager"
    ];
    description = "Default vijay user";
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

  system.stateVersion = "24.05";
}
