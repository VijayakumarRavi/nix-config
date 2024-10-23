{
  lib,
  pkgs,
  config,
  inputs,
  variables,
  ...
}: {
  # Import coustom pkgs
  imports = [../../pkgs];
  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    package = pkgs.nix;
    settings = {
      allowed-users = ["${variables.username}"];
      trusted-users = ["root" "${variables.username}"];
      experimental-features =
        ["nix-command" "flakes"]
        ++ lib.optional (lib.versionOlder (lib.versions.majorMinor config.nix.package.version) "2.22") "repl-flake";
      accept-flake-config = true;
      auto-optimise-store = true;
      connect-timeout = 5;
      warn-dirty = false;
      # disabled sandbox because of below error after adding vjvim flake
      # "> sandbox-exec: pattern serialization length 70044 exceeds maximum (65535)"
      sandbox = false;
      substituters = [
        "https://cache.nixos.org"
        "https://vijay.cachix.org"
        "https://numtide.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "vijay.cachix.org-1:6Re6EF3Q58sxaIobAWP1QTwMUCSA0nYMrSJGUedL3Zk="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = ["/etc/nix/path"] ++ lib.mapAttrsToList (flakeName: _: "${flakeName}=flake:${flakeName}") flakeInputs;
  };

  # BUG: if you remove these two lines you won't be able to access any nix programs
  programs.zsh.enable = true;
  users.users.${variables.username}.shell = pkgs.zsh;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Disable nix documentation
  # Notice this also disables --help for some commands such es nixos-rebuild
  documentation = {
    enable = lib.mkDefault false;
    info.enable = lib.mkDefault false;
    man.enable = lib.mkDefault false;
    #   nixos.enable = lib.mkDefault false;
  };

  environment = {
    shells = with pkgs; [zsh];
    #loginShell = pkgs.zsh;
    systemPackages = with pkgs; [
      # Linux utils
      fd # Simple, fast and user-friendly alternative to find
      vim # a must needed text editor
      curl # A command line tool for transferring files with URL syntax
      less # A more advanced file pager than 'more'
      wget # Internet file retriever
      htop # Improved top (interactive process viewer)
      btop # Resource monitor. C++ version and continuation of bashtop and bpytop
      gnupg # GnuPG key management tool
      p7zip # 7-Zip (high compression file archiver) implementation
      cowsay # ASCII cow
      rclone # Rsync for Cloud storage
      restic # A backup program that is fast, efficient and secure
      openssl # cryptographic library
      fastfetch # Fast, highly customisable system info script
      coreutils # GNU core utilities for Mac
      alejandra # formatter for Nix
      pkg-config # Manage compile and link flags for libraries
      inputs.nvim.packages.${pkgs.system}.default # custom neovim config

      # Ansible
      age # age is a simple, modern and secure file encryption tool.
      sops # Secret key encryption
      yamllint # YAML linter

      # Dev utils
      jq # JSON query tool
      gcc # c compiler
      tree # Tree command line tool
      iperf # Network performance test
      cachix # Command-line client for Nix binary cache hosting https://cachix.org
      attic-client # Multi-tenant Nix Binary Cache (self-hostede)
      python3 # Python lang
      unixtools.watch # Watch command line tool
      python311Packages.pip # install python dependencies

      # Containers
      fluxcd # Kubernetes GitOps
      kubectl # Kubernetes CLI tool
      helmfile # Declarative spec for deploying Helm charts
      kustomize # Customization of kubernetes YAML configurations
      lazydocker # docker TUI
      kubernetes-helm # A package manager for kubernetes
    ];
  };
}
