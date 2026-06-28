{
  pkgs,
  hostname,
  variables,
  modulesPath,
  inputs,
  config,
  ...
}: {
  # ISO settings & modules
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    inputs.impermanence.nixosModules.impermanence
    ../../modules/nixos
    ./disk-config.nix
  ];

  # Enable QEMU Guest Agent
  services.qemuGuest.enable = true;

  # ── Hardware & Bootloader ──────────────────────────────────────────────────
  boot = {
    initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_blk"];
    initrd.kernelModules = [];
    kernelModules = [];
    extraModulePackages = [];

    # Emulate an arm64 machine
    binfmt.emulatedSystems = ["aarch64-linux"];

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

  # ── Networking ─────────────────────────────────────────────────────────────
  networking = {
    hostName = hostname;
    useDHCP = false;
    interfaces.eth0 = {
      ipv4.addresses = [
        {
          address = "${variables.runner_ip}";
          prefixLength = 16;
        }
      ];
    };
    defaultGateway = "10.0.0.1";
    nameservers = ["1.1.1.1"];
  };

  # ── Impermanence ───────────────────────────────────────────────────────────
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
    '';
  };

  environment.persistence."/persist" = {
    enable = true;
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/var/lib/forgejo-runner" # Make sure runner data persists
      "/var/lib/docker" # Persist docker images/containers
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
  };

  # ── Core Services ──────────────────────────────────────────────────────────
  services.openssh.enable = true;
  virtualisation.docker = {
    enable = true; # Enable native docker suppor
    daemon.settings = {
      fixed-cidr-v6 = "fd00::/80";
      ipv6 = true;
    };
  };
  networking.firewall.trustedInterfaces = ["br-+"];

  users.users.builder = {
    isNormalUser = true;
    extraGroups = ["wheel" "builder" "docker"];
    shell = pkgs.zsh; # Follow modules/common shell defaults (programs.zsh.enable)
  };

  # ── Sops secrets for Forgejo Runner ───────────────────────────────────────
  # Add the following to secrets.yaml:
  #   forgejo_runner_token: "your-runner-token"
  #   forgejo_runner_uuid: "your-runner-uuid"
  #   forgejo_runner_url: "https://your.forgejo.url"

  sops.secrets.forgejo_runner_token = {restartUnits = ["forgejo-runner-native.service"];};
  sops.secrets.forgejo_runner_uuid = {restartUnits = ["forgejo-runner-native.service"];};
  sops.secrets.forgejo_runner_url = {restartUnits = ["forgejo-runner-native.service"];};

  # Generate the exact config.yaml requested using SOPS templates
  sops.templates."runner-config.yaml" = {
    owner = "forgejo-runner";
    group = "forgejo-runner";
    content = ''
      log:
        level: info
        job_level: info
      runner:
        file: .runner
        capacity: 3
        envs:
          DOCKER_HOST: "unix:///var/run/docker.sock"
          PATH: "/run/current-system/sw/bin:/run/wrappers/bin:/nix/var/nix/profiles/default/bin:/usr/local/bin:/usr/bin:/bin"
        timeout: 3h
        shutdown_timeout: 3h
        insecure: false
        fetch_timeout: 5s
        fetch_interval: 2s
        report_interval: 1s
        labels: [
          "nixos:host",
          "ubuntu-fat:docker://gitea/runner-images:ubuntu-latest",
          "ubuntu-25.04:docker://ubuntu:25.04",
          "ubuntu-24.04:docker://ubuntu:24.04",
          "ubuntu-22.04:docker://ubuntu:22.04",
          "debian-latest:docker://debian:13",
          "debian-12:docker://debian:12",
          "debian-11:docker://debian:11",
          "node-debian:docker://node:20-bookworm",
          "node-20-debian-12:docker://node:20-bookworm",
          "node-20-debian-11:docker://node:20-bullseye",
          "docker-cli:docker://code.forgejo.org/oci/docker:cli",
          "dotnet-sdk:docker://mcr.microsoft.com/dotnet/sdk:9.0",
          "dotnet-sdk-9:docker://mcr.microsoft.com/dotnet/sdk:9.0"
        ]
      cache:
        enabled: true
        port: 0
        dir: ""
        external_server: ""
        secret: ""
        secret_url: ""
        host: ""
        proxy_port: 0
        actions_cache_url_override: ""
      container:
        network: ""
        enable_ipv6: false
        privileged: true
        options: "-v /var/run/docker.sock:/var/run/docker.sock"
        workdir_parent:
        valid_volumes:
          - "/var/run/docker.sock"
        docker_host: ""
      host:
        workdir_parent:
      server:
        connections:
          forgejo:
            url: ${config.sops.placeholder.forgejo_runner_url}
            uuid: ${config.sops.placeholder.forgejo_runner_uuid}
            token: ${config.sops.placeholder.forgejo_runner_token}
    '';
  };

  # ── Forgejo runner service ────────────────────────────────────────────────
  # Grant the runner user access to the Nix daemon (overriding the strict allowed-users from common)
  nix.settings.allowed-users = ["forgejo-runner"];
  nix.settings.trusted-users = ["forgejo-runner"];

  # Global packages for the runner host (making them available in /run/current-system/sw/bin)
  environment.systemPackages = with pkgs; [
    forgejo-runner
    docker
    nix
    bash
    nodejs
    curl
    wget
    cacert
    git
  ];

  # We use systemd directly to run the forgejo-runner with the generated config
  systemd.services.forgejo-runner-native = {
    description = "Forgejo Runner";
    after = ["network.target" "docker.service"];
    requires = ["docker.service"];
    wantedBy = ["multi-user.target"];
    # Packages are also in systemPackages, but we keep them here for daemon execution
    path = config.environment.systemPackages;
    serviceConfig = {
      ExecStart = "${pkgs.forgejo-runner}/bin/forgejo-runner daemon --config ${config.sops.templates."runner-config.yaml".path}";
      User = "forgejo-runner";
      Group = "forgejo-runner";
      WorkingDirectory = "/var/lib/forgejo-runner";
      Restart = "always";
      RestartSec = "10s";
    };
    restartTriggers = [
      config.sops.templates."runner-config.yaml".content
    ];
  };

  users.users.forgejo-runner = {
    isSystemUser = true;
    group = "forgejo-runner";
    home = "/var/lib/forgejo-runner";
    createHome = true;
    extraGroups = ["docker"]; # Allow runner to use docker socket
  };
  users.groups.forgejo-runner = {};

  # State version
  system.stateVersion = variables.stateVersion;
}
