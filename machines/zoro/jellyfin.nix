{ pkgs, ... }:

{
  services.jellyfin = { enable = true; };

  services.nginx.virtualHosts = {
    "jellyfin.local" = { locations."/".proxyPass = "http://localhost:8096"; };

    "jellyfin.service" = { locations."/".proxyPass = "http://localhost:8096"; };
  };

  environment.systemPackages = [ pkgs.ffmpeg pkgs.intel-gpu-tools ];

  users.groups.nas.gid = 998;
  users.users.jellyfin.extraGroups = [ "nas" ];

  # firewall rule to allow jellyfin
  networking.firewall = {
    allowedTCPPorts = [ 8096 ];
    allowedUDPPorts = [ 8096 ];
  };

  hardware.opengl = {
    enable = true;
    extraPackages = [
      # Hardware transcoding.
      pkgs.intel-media-driver # LIBVA_DRIVER_NAME=iHD
      pkgs.libvdpau-va-gl
      pkgs.vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but can work better for some applications)
      pkgs.vaapiVdpau
      # HDR tone mapping.
      # pkgs.beignet
      pkgs.intel-compute-runtime
      pkgs.ocl-icd
    ];

    driSupport32Bit = true;

    extraPackages32 = [
      # Hardware transcoding.
      pkgs.intel-media-driver # LIBVA_DRIVER_NAME=iHD
      pkgs.libvdpau-va-gl
      pkgs.vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but can work better for some applications)
      pkgs.vaapiVdpau
      # HDR tone mapping.
      #pkgs.beignet
      pkgs.intel-compute-runtime
      pkgs.ocl-icd
    ];
  };
}
