# pgbackrest-exporter — pgBackRest backup metrics
# Custom package (not in nixpkgs). Reads pgbackrest info --output json.
# Conditional: only enabled when services.monitoring.exporters.pgbackrest.enable = true
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.monitoring;
  listenAddr =
    if cfg.wireguard.enable
    then lib.head (builtins.match "([^/]+)/.*" cfg.wireguard.address)
    else "127.0.0.1";
in {
  config = lib.mkIf (cfg.enable && cfg.exporters.pgbackrest.enable) {
    # ── Systemd service for pgbackrest_exporter ─────────────────────────
    systemd.services.pgbackrest-exporter = {
      description = "Prometheus exporter for pgBackRest";
      after = ["network.target" "postgresql.service"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.pgbackrest_exporter}/bin/pgbackrest_exporter --web.listen-address=${listenAddr}:9854 --backrest.config=${config.sops.templates."pgbackrest.conf".path}";
        Restart = "always";
        RestartSec = "10s";
        # Run as postgres user to access pgBackRest config and stanza info
        User = "postgres";
        Group = "postgres";
        # Hardening
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        ReadOnlyPaths = ["/"];
        ReadWritePaths = ["/tmp"];
      };

      # pgbackrest_exporter needs pgbackrest binary in PATH
      path = [pkgs.pgbackrest];
    };

    nixpkgs.overlays = [
      (final: _prev: {
        pgbackrest_exporter = final.buildGoModule rec {
          pname = "pgbackrest_exporter";
          version = "0.22.0";

          src = final.fetchFromGitHub {
            owner = "woblerr";
            repo = "pgbackrest_exporter";
            rev = "v${version}"; # tags/v*
            hash = "sha256-iT2LwbnghTiZ97dhf7EiaehPIze7DKCjVxv0ihTIb50=";
          };

          vendorHash = null; # Vendored dependencies are included in the source tree

          ldflags = [
            "-s"
            "-w"
            "-X main.version=${version}"
          ];

          meta = with final.lib; {
            description = "Prometheus exporter for pgBackRest";
            homepage = "https://github.com/woblerr/pgbackrest_exporter";
            license = licenses.mit;
            mainProgram = "pgbackrest_exporter";
          };
        };
      })
    ];
  };
}
