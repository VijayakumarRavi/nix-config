# wireguard-exporter — WireGuard interface and peer metrics
# Automatically enabled when monitoring and wireguard tunnel are active.
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
  config = lib.mkIf (cfg.enable && (cfg.exporters.wireguard.enable || cfg.wireguard.enable)) {
    services.prometheus.exporters.wireguard = {
      enable = true;
      port = 9586;
      listenAddress = listenAddr;
      withRemoteIp = true;
      latestHandshakeDelay = true;
    };
  };
}
