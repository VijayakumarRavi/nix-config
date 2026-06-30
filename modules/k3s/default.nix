{
  pkgs,
  lib,
  hostname,
  config,
  variables,
  ...
}: {
  options.services.k3sCluster = {
    enable = lib.mkEnableOption "K3s cluster node";
  };

  config = lib.mkIf config.services.k3sCluster.enable {
    # ── Hardware: Intel GPU drivers ────────────────────────────────────────
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        # Hardware transcoding.
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        libvdpau-va-gl
        intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but can work better for some applications)
        libva-vdpau-driver
        libva-utils
        # HDR tone mapping.
        intel-compute-runtime
        ocl-icd
      ];
      extraPackages32 = with pkgs; [
        # Hardware transcoding.
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        libvdpau-va-gl
        intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but can work better for some applications)
        libva-vdpau-driver
        libva-utils
        # HDR tone mapping.
        intel-compute-runtime
        ocl-icd
      ];
    };

    # ── Kernel: Intel-specific settings ───────────────────────────────────
    boot = {
      # Emulate an arm64 machine for RPI
      binfmt.emulatedSystems = ["aarch64-linux"];

      kernelParams = [
        "hugepagesz=2M" # Set the hugepage size to 2MiB
        "hugepages=512" # Set the number of hugepages to 2048
      ];

      kernel.sysctl = {
        "fs.inotify.max_queued_events" = 524288;
        "fs.inotify.max_user_instances" = 16383;
        "fs.inotify.max_user_watches" = 524288;
      };
    };

    # ── Bootloader ────────────────────────────────────────────────────────
    # Note: Bootloader is configured in the host's default.nix since
    # it's host-specific (grub settings, etc.)

    # ── K3s Services ──────────────────────────────────────────────────────
    services.k3s = {
      enable = true;
      role = "server";
      tokenFile = config.sops.secrets.kubetoken.path;
      extraFlags = toString (
        [
          "--write-kubeconfig-mode \"0644\""
          "--cluster-init"
          "--disable traefik"
          "--disable servicelb"
          "--disable local-storage"
          "--tls-san \"cluster.home.vijayakumar.xyz\""
        ]
        ++ (
          if hostname == "zoro"
          then []
          else ["--server https://${variables.zoro_ip}:6443"]
        )
      );
      clusterInit = hostname == "zoro";
    };

    services.openiscsi = {
      enable = true;
      name = "iqn.2016-04.com.open-iscsi:${hostname}";
    };

    # ── NFS Server ────────────────────────────────────────────────────────
    services.nfs.server = {
      enable = true;
      # fixed rpc.statd port; for firewall
      lockdPort = 4001;
      mountdPort = 4002;
      statdPort = 4000;
      exports = ''
        /mnt/share     *(rw,sync,wdelay,hide,no_subtree_check,fsid=0,sec=sys,insecure,no_root_squash,no_all_squash)
      '';
    };

    # ── Packages ──────────────────────────────────────────────────────────
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

    # Fixes for longhorn
    systemd.tmpfiles.rules = ["L+ /usr/local/bin - - - - /run/current-system/sw/bin/"];
  };
}
