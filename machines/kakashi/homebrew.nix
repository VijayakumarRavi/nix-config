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
    mutableTaps = false;
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
      "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
      "homebrew/homebrew-services" = inputs.homebrew-services;
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
      "nginx" # Reverse proxy to use as a loadbalancer for kubectl
      "aria2" # download manager
      "flyctl" # fly.io cli tool
      "bitwarden-cli" # free password manager
      "mas" # Mac appstore installer
      "pinentry-mac" # GPG key entry utility
      "node" # Node js
    ];
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
      "balenaetcher" # Tool to flash OS images to SD cards & USB drives
      "raspberry-pi-imager" # Raspberry Pi Imager to flash sd cards
      "background-music" # macOS audio utility to record system audio
      "stats" # System monitor for the menu bar
      "raycast" # Raycast - A better alternative to Alfred and spotlight
      "appcleaner" # Application uninstaller
      "visual-studio-code" # Visual Studio Code editor
    ];
    masApps = {
      "1Password for Safari" = 1569813296;
      "Tailscale" = 1475387142;
      "infuse video player" = 1136220934;
      "localsend" = 1661733229;
      "shortery" = 1594183810;
      "Hyperduck" = 6444667067;
      # "shelly ssh client" = 989642999;
    };
  };
}
