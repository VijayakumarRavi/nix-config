{ config, ... }:
{
  homebrew = {
    enable = true;
    caskArgs.no_quarantine = true;
    global.brewfile = true;
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };
    taps = builtins.attrNames config.nix-homebrew.taps;
    brews = [ "nginx" "aria2" ]; # Reverse proxy to use as a loadbalancer for kubectl
    casks = [
      # Better mac
      "shottr" # Screenshot util
      "brave-browser" # Web browser focusing on privacy
      "arc" # Chromium based browser
      "hyperkey" # Convert your caps lock key or any of your modifier keys to the hyper key
      "the-unarchiver" # Unpacks archive files
      "onyx" # Verify system files structure, run miscellaneous maintenance and more
      "1password" # Best password manager imo
      "1password-cli" # 1Password manager CLI
      "bartender" # Menu bar icon organizer
      "google-drive" # Google cloud storage
      "beeper" # Universal chat app powered by Matrix
      "github" # Desktop client for GitHub repositories
    ];
    masApps = {
      "1Password for Safari" = 1569813296;
      "Tailscale" = 1475387142;
      "infuse video player" = 1136220934;
      "localsend" = 1661733229;
      "shortery" = 1594183810;
      # "shelly ssh client" = 989642999;
    };
  };
}
