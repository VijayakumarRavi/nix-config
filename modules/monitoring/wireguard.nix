# WireGuard monitoring tunnel
# Creates a point-to-point encrypted tunnel between Robin and Zoro
# for secure metric scraping and log shipping.
#
# NOTE: WireGuard public keys are NOT secrets — they can be stored in plain
# text in the nix config. Only private keys need sops protection.
# The peer endpoint (Robin's public IP) is sensitive and stored in sops.
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.monitoring;
  wgCfg = cfg.wireguard;
in {
  options.services.monitoring.wireguard = {
    peerPublicKey = lib.mkOption {
      type = lib.types.str;
      description = "Peer's WireGuard public key (not a secret — safe to store in nix config)";
      example = "aBcDeFgHiJkLmNoPqRsTuVwXyZ0123456789aBcDeFg=";
    };
  };

  config = lib.mkIf (cfg.enable && wgCfg.enable) {
    # ── Sops secrets for WireGuard ──────────────────────────────────────
    sops.secrets =
      {
        ${wgCfg.privateKeySecret} = {};
      }
      // lib.optionalAttrs (wgCfg.peerEndpointSecret != null) {
        ${wgCfg.peerEndpointSecret} = {};
      };

    # ── WireGuard interface ─────────────────────────────────────────────
    networking.wireguard.interfaces.wg-monitor = {
      ips = [wgCfg.address];
      listenPort = wgCfg.listenPort;
      privateKeyFile = config.sops.secrets.${wgCfg.privateKeySecret}.path;

      peers = [
        ({
            publicKey = wgCfg.peerPublicKey;
            allowedIPs = wgCfg.peerAllowedIPs;
            # Keep tunnel alive (needed for NAT traversal when Zoro initiates)
            persistentKeepalive = 25;
          }
          // lib.optionalAttrs (wgCfg.peerEndpointSecret != null) {
            # Endpoint is set via a dynamic setup script below
            # (can't set it statically because it's in a sops secret)
          })
      ];
    };

    # ── Dynamic endpoint from sops secret ───────────────────────────────
    # WireGuard's NixOS module doesn't support reading endpoint from a file,
    # so we use a oneshot service to set it after sops decryption.
    systemd.services.wg-monitor-endpoint = lib.mkIf (wgCfg.peerEndpointSecret != null) {
      description = "Set WireGuard monitor peer endpoint from sops secret";
      after = ["wireguard-wg-monitor.service"];
      wants = ["wireguard-wg-monitor.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        ENDPOINT=$(cat ${config.sops.secrets.${wgCfg.peerEndpointSecret}.path})
        ${pkgs.wireguard-tools}/bin/wg set wg-monitor peer "${wgCfg.peerPublicKey}" endpoint "$ENDPOINT"
      '';
      path = [pkgs.wireguard-tools];
    };

    # ── Firewall: allow WireGuard UDP port and trust the tunnel ─────────
    networking.firewall.allowedUDPPorts = [wgCfg.listenPort];
    networking.firewall.trustedInterfaces = ["wg-monitor"];
  };
}
