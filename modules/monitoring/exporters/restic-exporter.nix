# restic-exporter — Restic backup metrics
# Uses native NixOS services.prometheus.exporters.restic module.
# Conditional: only enabled when services.monitoring.exporters.restic.enable = true
#
# NOTE: Requires restic repository credentials and password in sops secrets.
# The environmentFile should contain credentials for the S3/remote backend.
{
  config,
  lib,
  ...
}: let
  cfg = config.services.monitoring;
  listenAddr =
    if cfg.wireguard.enable
    then lib.head (builtins.match "([^/]+)/.*" cfg.wireguard.address)
    else "127.0.0.1";
in {
  options.services.monitoring.exporters.restic = {
    repositoryFileSecret = lib.mkOption {
      type = lib.types.str;
      default = "restic_repository";
      description = "Sops secret name for the restic repository URI";
    };

    passwordFileSecret = lib.mkOption {
      type = lib.types.str;
      default = "restic_password";
      description = "Sops secret name for the restic repository password";
    };

    environmentFileSecret = lib.mkOption {
      type = lib.types.str;
      default = "restic_env";
      description = "Sops secret name for the restic environment file (S3 credentials etc.)";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.exporters.restic.enable) {
    # ── Sops secrets ────────────────────────────────────────────────────
    sops.secrets.${cfg.exporters.restic.repositoryFileSecret} = {};
    sops.secrets.${cfg.exporters.restic.passwordFileSecret} = {};
    sops.secrets.${cfg.exporters.restic.environmentFileSecret} = {};

    sops.templates."restic-exporter-repo".content = "${config.sops.placeholder.${cfg.exporters.restic.repositoryFileSecret}}/${config.networking.hostName}";

    # ── Native NixOS restic exporter ────────────────────────────────────
    services.prometheus.exporters.restic = {
      enable = true;
      port = 9753;
      listenAddress = listenAddr;
      repositoryFile = config.sops.templates."restic-exporter-repo".path;
      passwordFile = config.sops.secrets.${cfg.exporters.restic.passwordFileSecret}.path;
      environmentFile = config.sops.secrets.${cfg.exporters.restic.environmentFileSecret}.path;
      refreshInterval = 300; # Every 5 minutes (expensive operation)
    };

    nixpkgs.overlays = [
      (final: prev: {
        prometheus-restic-exporter = with final.python3Packages;
          buildPythonApplication rec {
            pname = "prometheus-restic-exporter";
            version = "2.1.2";
            pyproject = true;

            src = final.fetchFromGitHub {
              owner = "ngosang";
              repo = "restic-exporter";
              rev = version;
              hash = "sha256-n56LjQWZuAYB+jQoJT8KDMxmCxWa3zICYjlPq3PXxgQ=";
            };

            build-system = [setuptools];
            dependencies = [prometheus-client];

            postPatch = ''
              substituteInPlace exporter/exporter.py \
                --replace-fail '"restic"' '"${final.lib.getExe final.restic}"'
            '';

            postInstall = ''
              ln -s $out/bin/restic-exporter $out/bin/restic-exporter.py
            '';

            meta =
              (prev.prometheus-restic-exporter.meta or {})
              // {
                mainProgram = "restic-exporter";
              };
          };
      })
    ];
  };
}
