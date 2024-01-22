{ pkgs, ... }: {

  nix = {
    # package = lib.mkDefault pkgs.nix;
    package = pkgs.nix;
    settings = {
      allowed-users = [ "vijay" ];
      trusted-users = [ "root" "vijay" ];
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
      auto-optimise-store = true;
      warn-dirty = false;
      sandbox = false;
    };
  };

  programs.zsh.enable = true;
  # users.defaultUserShell = pkgs.zsh;
  users.users.vijay.shell = pkgs.zsh;
  environment = {
    shells = with pkgs; [ zsh ];
    #loginShell = pkgs.zsh;
    systemPackages = with pkgs; [
      # Linux utils
      vim # a must needed text editor
      fd # Simple, fast and user-friendly alternative to find
      curl # A command line tool for transferring files with URL syntax
      less # A more advanced file pager than 'more'
      coreutils # GNU core utilities for Mac
      cowsay # ASCII cow
      gnupg # GnuPG key management tool
      neofetch # Fast, highly customisable system info script
      wget # Internet file retriever
      p7zip # 7-Zip (high compression file archiver) implementation
      pkg-config # Manage compile and link flags for libraries
      htop # Improved top (interactive process viewer)
      btop # Resource monitor. C++ version and continuation of bashtop and bpytop
      lf # Terminal file manager
      atuin # sync shell history between machines
      prettyping # A wrapper around the standard ping tool

      #_1password-gui # Best password manager imo
      #_1password # 1Password manager CLI

      # Git
      gitflow # Better git flow
      lazygit # git TUI
      pre-commit # Git pre-commit hook
      git-crypt # file encryption in git

      # Ansible
      ansible # Ansible command line tool
      yamllint # YAML linter
      ansible-lint # Ansible linter
      age # age is a simple, modern and secure file encryption tool.
      sshpass # SSHPass - SSH password manager
      sops # Secret key encryption

      # Dev utils
      tree # Tree command line tool
      unixtools.watch # Watch command line tool
      jq # JSON query tool
      rustc # rust lang
      cargo # install rust dependencies
      gcc # C compiler
      rclone # Rsync for Cloud storage
      python3 # Python lang
      python311Packages.pip # install python dependencies
      cachix # Command-line client for Nix binary cache hosting https://cachix.org
      nixfmt # nix lang formatter
      flyctl # Fly.io tool
      iperf # Network performance test
      cloudflared # Cloudflare daemon
      terraform # terraform cli tool for managing infrastructure
      terraformer # CLI tool to generate terraform files from existing infrastructure (reverse Terraform). Infrastructure to Code

      # rpi-imager # Raspberry Pi Imaging Utility
      yt-dlp # Download youtube videos
      mpv # Video player
      pandoc # Markdown converter
      borgbackup # simple backup solution
      hugo # Static site generator
      spotify # Music client
      ncspot # ncurses Spotify client
      magic-wormhole # file transfer cli

      # Containers
      kubernetes-helm # A package manager for kubernetes
      kustomize # Customization of kubernetes YAML configurations
      kubectl # Kubernetes CLI tool
      lazydocker # docker TUI
    ];
  };
}
