{
  pkgs,
  hostname,
  config,
  variables,
  ...
}: {
  imports = [
    ../core
    ../core/linux.nix

    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    # Declarative disk partitioning config
    ./disk-config.nix
  ];

  # Bootloader
  boot = {
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
          menuentry 'UEFI Firmware Settings' --id 'uefi-firmware' {
            fwsetup
          }
        '';
      };
    };
    # Emulate an arm64 machine for RPI
    binfmt.emulatedSystems = ["aarch64-linux"];
  };

  # List services that you want to enable:
  services = {
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

  # Unattended upgrades
  system.autoUpgrade = {
    enable = true;
    dates = "*-*-* 04:00:00";
    allowReboot = true;
    persistent = true;
    rebootWindow = {
      lower = "03:00";
      upper = "05:00";
    };
    flags = ["--accept-flake-config"];
    flake = "github:VijayakumarRavi/nix-config";
  };

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    sbctl
    lm_sensors
    unzip
    unrar
    killall
    cifs-utils
    nfs-utils
    intel-gpu-tools # for intel gpu
  ];

  services.k3s = {
    enable = true;
    role = "server";
    tokenFile = config.sops.secrets.kubetoken.path;
    extraFlags = toString (
      [
        "--write-kubeconfig-mode \"0644\""
        "--cluster-init"
        "--disable servicelb"
        "--disable traefik"
        "--disable local-storage"
      ]
      ++ (
        if hostname == "zoro"
        then []
        else ["--server https://zoro:6443"]
      )
    );
    clusterInit = hostname == "zoro";
  };

  services.openiscsi = {
    enable = true;
    name = "iqn.2016-04.com.open-iscsi:${hostname}";
  };

  # Fixes for longhorn
  systemd.tmpfiles.rules = ["L+ /usr/local/bin - - - - /run/current-system/sw/bin/"];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = variables.stateVersion; # Did you read the comment?
}
