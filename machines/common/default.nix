{ pkgs, ... }:
{
  nix = {
    # package = lib.mkDefault pkgs.nix;
    package = pkgs.nix;
    settings = {
      allowed-users = [ "vijay" ];
      trusted-users = [
        "root"
        "vijay"
      ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      warn-dirty = false;
      sandbox = false;
    };
  };

  # BUG: if you remove these two lines you won't be able to access any nix programs
  programs.zsh.enable = true;
  users.users.vijay.shell = pkgs.zsh;

  #disable nix documentation
  documentation.enable = false;
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment = {
    shells = with pkgs; [ zsh ];
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
      neofetch # Fast, highly customisable system info script
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
