{
  config,
  inputs,
  variables,
  ...
}: {
  imports = [inputs.nix-homebrew.darwinModules.nix-homebrew];

  nix-homebrew = {
    enable = true;
    user = variables.username;
    enableRosetta = true;
    autoMigrate = true;
    mutableTaps = true;
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
      "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
      "homebrew/homebrew-services" = inputs.homebrew-services;
      "VijayakumarRavi/packages" = inputs.homebrew-vijay;
    };
  };

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
    brews = [
      "flyctl" # fly.io cli tool
      "bitwarden-cli" # free password manager
      "mas" # Mac appstore installer
      "pinentry-mac" # GPG key entry utility
      "node" # Node js
      # "docker" # docker cli
      # "podman" # docker alternative
    ];
    casks = [
      # Better mac
      "shottr" # Screenshot util
      "brave-browser" # Web browser focusing on privacy
      "the-unarchiver" # Unpacks archive files
      "1password" # Best password manager imo
      "1password-cli" # 1Password manager CLI
      # "jordanbaird-ice" # macOS status bar icon organizer
      "jordanbaird-ice@beta" # switching to beta to fix https://github.com/jordanbaird/Ice/issues/709
      "google-drive" # Google cloud storage
      "beeper" # Universal chat app powered by Matrix
      "github" # Desktop client for GitHub repositories
      "raspberry-pi-imager" # Raspberry Pi Imager to flash sd cards
      "background-music" # macOS audio utility to record system audio
      "stats" # System monitor for the menu bar
      "raycast" # Raycast - A better alternative to Alfred and spotlight
      "pearcleaner" # Application uninstaller
      "visual-studio-code" # Visual Studio Code editor
      "amazon-workspaces" # amazon-workspaces for FPL
      "rave" # App for watching videos and listening to music with friends in real-time
      "ghostty" # Ghostty is a fast, feature-rich, and cross-platform terminal emulator
      "zen" # Gecko based web browser
      "ente" # Desktop client for Ente Photos
      "antigravity" # Google Antigravity AI
      "antigravity-cli" # Google Antigravity AI CLI
    ];
    masApps = {
      "1Password for Safari" = 1569813296;
      "Tailscale" = 1475387142;
      "infuse video player" = 1136220934;
      "localsend" = 1661733229;
      "shortery" = 1594183810;
      "Bitwarden" = 1352778147;
    };
  };
}
