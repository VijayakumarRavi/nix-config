let
  pkgs = import <nixpkgs> { system = "x86_64-linux"; };
  eval = pkgs.lib.evalModules {
    modules = [
      (pkgs.path + "/nixos/modules/services/monitoring/prometheus/alertmanager.nix")
      {
        services.prometheus.alertmanager.enable = true;
      }
    ];
  };
in
eval.config.systemd.services.alertmanager.preStart
