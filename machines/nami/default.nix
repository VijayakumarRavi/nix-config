{
  config,
  inputs,
  variables,
  ...
}: {
  imports = [
    inputs.raspberry-pi-nix.nixosModules.raspberry-pi
    inputs.raspberry-pi-nix.nixosModules.sd-image

    ../core
    ../core/linux.nix

    # Containers
    ./compose.nix

    # RPI5 fan controller
    ./fan_controller.nix
  ];

  nixpkgs.hostPlatform = "aarch64-linux";

  # bcm2711 for rpi 3, 3+, 4, zero 2 w
  # bcm2712 for rpi 5
  # See the docs at:
  # https://www.raspberrypi.com/documentation/computers/linux_kernel.html#native-build-configuration
  raspberry-pi-nix.board = "bcm2712";

  # uboot not yet supported for pi5
  # https://github.com/tstat/raspberry-pi-nix/issues/13#issuecomment-2090601812
  raspberry-pi-nix.uboot.enable = false;
  # https://github.com/nix-community/raspberry-pi-nix/issues/24#issuecomment-2185314220
  boot.initrd.systemd.enable = false;

  # If enabled then the libcamera overlay is applied which overrides libcamera with the rpi fork.
  raspberry-pi-nix.libcamera-overlay.enable = false;

  sdImage = {
    imageName = "NixPi.img";
    compressImage = true;
  };

  networking = {
    networkmanager.enable = true;
    useDHCP = false;
    interfaces = {
      wlan0.useDHCP = true;
      eth0.useDHCP = true;
    };
  };

  # List services that you want to enable
  services = {
    pi5_fan_controller.enable = true;

    pipewire.enable = false;

    tailscale = {
      enable = true;
      openFirewall = true;
      extraUpFlags = ["--advertise-tags=tag:cluster" "--accept-routes" "--reset" "--advertise-routes=10.0.0.0/16" "--advertise-exit-node"];
      authKeyFile = config.sops.secrets.tailscale_authkey.path;
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
