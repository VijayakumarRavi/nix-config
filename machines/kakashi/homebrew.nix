# { pkgs, ... }:
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
    masApps = {
      "1Password for Safari" = 1569813296;
      "Tailscale" = 1475387142;
      "infuse video player" = 1136220934;
      "localsend" = 1661733229;
      "shortery" = 1594183810;
      # "shelly ssh client" = 989642999;
    };
    casks = [
      # Better mac
      "raycast" # Raycast - A better alternative to Alfred and spotlight
      "stats" # System monitor for the menu bar
      "shottr" # Screenshot util
      "brave-browser" # Web browser focusing on privacy
      "arc" # Chromium based browser
      "hyperkey" # Convert your caps lock key or any of your modifier keys to the hyper key
      "appcleaner" # Application uninstaller
      "the-unarchiver" # Unpacks archive files
      "github" # Desktop client for GitHub repositories
      "bartender" # Menu bar icon organizer
      "onyx" # Verify system files structure, run miscellaneous maintenance and more
      "beeper" # Universal chat app powered by Matrix
      "visual-studio-code" # Visual Studio Code editor
      "1password" # Best password manager imo
      "1password-cli" # 1Password manager CLI
      "google-drive" # Google cloud storage
      #"koekeishiya/formulae/skhd"
    ];
    taps = [
      # "1password/tap" # Best password manager
      # "hudochenkov/sshpass" # Ansible sshpass
      # "cloudflare/cloudflare" # Cloudflare CLI tool
      # "hashicorp/tap" # Hashicorp tap
    ];
    brews = [
      # Utils
      "pinentry-mac" # GPG key entry utility
      "mas" # Mac appstore installer
      "docker-clean" # Clean Docker containers, images, networks, and volumes
    ];
  };
}
