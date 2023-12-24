#{ pkgs, ... }: 
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
      # "shelly ssh client" = 989642999;
    };
    casks = [
      # Better mac
      "hpedrorodrigues/tools/dockutil" # Dockutil - Manage your dock
      "iterm2" # Terminal emulator
      "raycast" # Raycast - A better alternative to Alfred and spotlight
      "stats" #System monitor for the menu bar
      "shottr" # Screenshot util
      "brave-browser" # Web browser focusing on privacy
      "arc" # Chromium based browser
      "spotify" # Music streaming service
      "hyperkey" # Convert your caps lock key or any of your modifier keys to the hyper key
      "appcleaner" # Application uninstaller
      "the-unarchiver" # Unpacks archive files
      "github" # Desktop client for GitHub repositories
      "bartender" # Menu bar icon organizer
      "onyx" # Verify system files structure, run miscellaneous maintenance and more
      "beeper" # Universal chat app powered by Matrix
      "visual-studio-code" # Visual Studio Code editor
    ];
    taps = [
      # Homebrew
      "homebrew/bundle" # Homebrew Bundle
      "homebrew/cask" # Homebrew Cask
      "homebrew/core" # Homebrew Core
      "homebrew/services" # Homebrew Services

      "1password/tap" # Best password manager
      "hudochenkov/sshpass" # Ansible sshpass 
      "cloudflare/cloudflare" # Cloudflare CLI tool
      "hashicorp/tap" # Hashicorp tap
    ];
    brews = [
      # Utils
      "pinentry-mac" # GPG key entry utility
      "kubernetes-cli" # Kubernetes CLI tool
      "mas" # Mac appstore installer
      "docker-clean" # Clean Docker containers, images, networks, and volumes
    ];
  };
}
