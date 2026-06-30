# pgbackrest_exporter — Prometheus exporter for pgBackRest
# Source: https://github.com/woblerr/pgbackrest_exporter
# Packaged manually because it's not in nixpkgs.
#
# This module adds the package to the system via nixpkgs overlay so it
# can be referenced as `pkgs.pgbackrest_exporter` anywhere in the config.
{pkgs, ...}: let
  pgbackrest_exporter = pkgs.buildGoModule rec {
    pname = "pgbackrest_exporter";
    version = "0.23.0";

    src = pkgs.fetchFromGitHub {
      owner = "woblerr";
      repo = "pgbackrest_exporter";
      rev = "v${version}";
      hash = "sha256-iT2LwbnghTiZ97dhf7EiaehPIze7DKCjVxv0ihTIb50=";
    };

    vendorHash = null; # Vendored dependencies are included in the source tree

    ldflags = [
      "-s"
      "-w"
      "-X main.version=${version}"
    ];

    meta = with pkgs.lib; {
      description = "Prometheus exporter for pgBackRest";
      homepage = "https://github.com/woblerr/pgbackrest_exporter";
      license = licenses.mit;
      mainProgram = "pgbackrest_exporter";
    };
  };
in {
  nixpkgs.overlays = [
    (_final: _prev: {
      inherit pgbackrest_exporter;
    })
  ];
}
