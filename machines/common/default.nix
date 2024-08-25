{
  lib,
  pkgs,
  config,
  inputs,
  variables,
  ...
}: {
  imports = [inputs.agenix.nixosModules.default];

  nix = {
    package = pkgs.nix;
    settings = {
      allowed-users = ["${variables.username}"];
      trusted-users = [
        "root"
        "${variables.username}"
      ];
      experimental-features =
        [
          "nix-command"
          "flakes"
        ]
        ++ lib.optional (lib.versionOlder (lib.versions.majorMinor config.nix.package.version) "2.22") "repl-flake";
      auto-optimise-store = true;
      connect-timeout = 5;
      warn-dirty = false;
      sandbox = false;
    };
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
      pkg-config # Manage compile and link flags for libraries

      # Git
      lazygit # git TUI
      git-crypt # file encryption in git
      pre-commit # Git pre-commit hook

      # Ansible
      age # age is a simple, modern and secure file encryption tool.
      sops # Secret key encryption
      yamllint # YAML linter

      # Dev utils
      jq # JSON query tool
      gcc # c compiler
      tree # Tree command line tool
      just # Handy way to save and run project-specific commands AKA justfile
      iperf # Network performance test
      cachix # Command-line client for Nix binary cache hosting https://cachix.org
      python3 # Python lang
      unixtools.watch # Watch command line tool
      python311Packages.pip # install python dependencies
      #nixfmt-rfc-style # nix lang formatter

      # Containers
      kubectl # Kubernetes CLI tool
      helmfile # Declarative spec for deploying Helm charts
      kustomize # Customization of kubernetes YAML configurations
      lazydocker # docker TUI
      kubernetes-helm # A package manager for kubernetes
    ];
  };
}
