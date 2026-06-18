{
  lib,
  pkgs,
  hostname,
  variables,
  modulesPath,
  inputs,
  config,
  ...
}: {
  # ISO settings
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    inputs.impermanence.nixosModules.impermanence
    ../../modules/common
    ../../modules/nixos
    ./disk-config.nix

    ./proxy.nix
    ./postgresql.nix
    ./pocketid.nix
    ./lldap.nix
    ./ente.nix
    ./fail2ban.nix
  ];

  boot = {
    initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_blk"];
    initrd.kernelModules = [];
    kernelModules = [];
    extraModulePackages = [];
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

  networking = {
    # Hostname
    hostName = hostname;
    useDHCP = lib.mkDefault true;
    nameservers = ["1.1.1.1"];
    # PostgreSQL: SSL-only remote connections
    firewall.allowedTCPPorts = [24957];
  };

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    lm_sensors
    unzip
    killall
  ];

  environment.persistence."/persist" = {
    enable = true;
    hideMounts = true;
    directories = [
      "/var/lib/nixos"
      "/var/log"
      "/var/lib/systemd/coredump"
      "/var/lib/postgresql" # PostgreSQL data
      "/var/lib/acme" # Let's Encrypt certificates
      "/var/lib/pocket-id" # Pocket ID OIDC data
      "/var/lib/nginx" # Nginx state and log directories
      "/var/lib/private/lldap" # LLDAP data and bootstrapped secrets
      "/var/lib/ente" # Ente state directories
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
  };

  fileSystems."/persist".neededForBoot = true;

  boot.initrd.systemd.services.rollback = {
    description = "Rollback BTRFS root subvolume to a pristine state";
    wantedBy = ["initrd.target"];
    after = ["systemd-cryptsetup@enc.service"]; # wait for luks if applicable
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

  sops.secrets.restic-password = {};
  sops.secrets.restic-repository = {};
  sops.secrets.restic-env = {};

  sops.templates."restic-repository-${config.networking.hostName}".content = ''
    ${config.sops.placeholder.restic-repository}/${config.networking.hostName}
  '';

  services.restic.backups.apps = {
    repositoryFile = config.sops.templates."restic-repository-${config.networking.hostName}".path;
    passwordFile = config.sops.secrets.restic-password.path;
    environmentFile = config.sops.secrets.restic-env.path;
    initialize = true;
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
      RandomizedDelaySec = "5m";
    };

    paths = ["/persist-backup-snapshot"];
    pruneOpts = ["--keep-hourly 24" "--keep-daily 7" "--keep-weekly 4" "--keep-monthly 6"];

    backupPrepareCommand = ''
      PING_URL=$(cat ${config.sops.secrets.robin_hc_url.path})
      ${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 -o /dev/null $PING_URL/start || true

      if [ -d /persist-backup-snapshot ]; then
        echo "WARNING: previous run did not cleanly finish, removing old snapshot"
        ${pkgs.btrfs-progs}/bin/btrfs subvolume delete /persist-backup-snapshot
      fi
      ${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot -r /persist /persist-backup-snapshot
    '';

    backupCleanupCommand = ''
      ${pkgs.btrfs-progs}/bin/btrfs subvolume delete /persist-backup-snapshot
      PING_URL=$(cat ${config.sops.secrets.robin_hc_url.path})
      if [ "$EXIT_STATUS" = "0" ]; then
        ${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 -o /dev/null $PING_URL || true
      else
        ${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 -o /dev/null $PING_URL/fail || true
      fi
    '';
  };

  # Disable PrivateMounts so restic ExecStart can see the snapshot created in ExecStartPre
  systemd.services."restic-backups-apps".serviceConfig.PrivateMounts = lib.mkForce false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = variables.stateVersion; # Did you read the comment?
}
