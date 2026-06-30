# node-exporter — system metrics (CPU, memory, disk, network, etc.)
# Always enabled when monitoring is active.
{
  config,
  lib,
  ...
}: let
  cfg = config.services.monitoring;
  # Bind to WireGuard IP if tunnel is enabled, otherwise localhost
  listenAddr =
    if cfg.wireguard.enable
    then lib.head (builtins.match "([^/]+)/.*" cfg.wireguard.address)
    else "127.0.0.1";
in {
  config = lib.mkIf cfg.enable {
    services.prometheus.exporters.node = {
      enable = true;
      port = 9100;
      listenAddress = listenAddr;
      enabledCollectors = [
        "systemd"
        "textfile"
        "processes"
      ];
      extraFlags = [
        "--collector.textfile.directory=/var/lib/node-exporter/textfile"
      ];
    };

    # Ensure the textfile collector directory exists
    systemd.tmpfiles.rules = [
      "d /var/lib/node-exporter/textfile 0755 root root -"
    ];
  };
}
