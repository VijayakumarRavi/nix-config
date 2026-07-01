{
  lib,
  pkgs,
  config,
  hostname,
  variables,
  inputs,
  modulesPath,
  ...
}: {
  imports = [
    inputs.impermanence.nixosModules.impermanence
    ../../../modules/nixos
    ../../../modules/k3s
    ../../../modules/monitoring
    ./disk-config.nix
  ];

  # ── Hardware ────────────────────────────────────────────────────────────
  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "nvme"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];
    initrd.kernelModules = [];
    kernelModules = ["kvm-intel"];
    extraModulePackages = [];

    loader = {
      efi.canTouchEfiVariables = true;
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
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  networking.useDHCP = lib.mkDefault true;
  networking.usePredictableInterfaceNames = false;

  # ── Networking ──────────────────────────────────────────────────────────
  networking.interfaces = {
    eth0 = {
      ipv4.addresses = [
        {
          address = "${variables.zoro_ip}";
          prefixLength = 16;
        }
      ];
    };
  };

  # ── Impermanence ────────────────────────────────────────────────────────
  fileSystems."/persist".neededForBoot = true;

  boot.initrd.systemd.services.rollback = {
    description = "Rollback BTRFS root subvolume to a pristine state";
    wantedBy = ["initrd.target"];
    after = ["systemd-cryptsetup@enc.service"];
    before = ["sysroot.mount"];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p /btrfs_tmp
      mount -t btrfs -o subvol=/ /dev/disk/by-partlabel/disk-nixos-root /btrfs_tmp
      if [[ -e /btrfs_tmp/root ]]; then
          mkdir -p /btrfs_tmp/old_roots
          timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
          mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
      fi

      delete_subvolume_recursively() {
          IFS=$'\n'
          for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
              delete_subvolume_recursively "/btrfs_tmp/$i"
          done
          btrfs subvolume delete "$1"
      }

      for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
          delete_subvolume_recursively "$i"
      done

      btrfs subvolume create /btrfs_tmp/root
      umount /btrfs_tmp
      rmdir /btrfs_tmp
    '';
  };

  environment.persistence."/persist" = {
    enable = true;
    hideMounts = true;
    directories = [
      "/var/lib/nixos"
      "/var/log"
      "/var/lib/systemd/coredump"
      # Monitoring stack
      "/var/lib/prometheus2"
      "/var/lib/grafana"
      "/var/lib/loki"
      "/var/lib/acme"
      "/var/lib/nginx"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
  };


  # ── K3s — disabled (re-enable when new nodes available) ─────────────────
  services.k3sCluster.enable = false;

  # ── Monitoring Stack Hub ────────────────────────────────────────────────
  services.monitoring = {
    enable = true;
    role = "hub";
    wireguard = {
      enable = true;
      address = "10.100.0.2/24";
      peerPublicKey = "R0FuJwsyuPtU8wP2xhgJV25khHwDA5MCpWZ88M7FDQg="; # Robin's WG public key
      privateKeySecret = "wg_monitor_zoro_private_key";
      peerEndpointSecret = "robin_public_endpoint";
    };
    targets = [
      {
        host = "10.100.0.1";
        name = "robin";
        exporters = ["node" "postgres" "pgbackrest" "restic" "nginx" "systemd" "blackbox" "fail2ban"];
      }
      {
        host = "10.100.0.2";
        name = "zoro";
        exporters = ["node" "blackbox" "nginx" "systemd"];
      }
      {
        host = variables.runner_ip;
        name = "runner";
        exporters = ["node" "systemd"];
      }
    ];
    exporters = {
      nginx.enable = true;
    };
  };

  # ── State version ──────────────────────────────────────────────────────
  system.stateVersion = variables.stateVersion;
}
