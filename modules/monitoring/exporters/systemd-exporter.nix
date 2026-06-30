# systemd-exporter — systemd unit and timer metrics
# Always enabled when monitoring is active.
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
  config = lib.mkIf cfg.enable {
    services.prometheus.exporters.systemd = {
      enable = true;
      port = 9558;
      listenAddress = listenAddr;
    };
  };
}
