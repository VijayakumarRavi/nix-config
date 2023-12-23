{ pkgs, ... }: {
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
      # "shelly ssh client" = 989642999;
    };
    casks = [
        # Better mac
        "hpedrorodrigues/tools/dockutil" # Dockutil - Manage your dock
        "iterm2" # Terminal emulator
        "raycast" # Raycast - A better alternative to Alfred and spotlight
        "stats" 
        "shottr" # Screenshot util
        "spotify" # Music streaming service
        "1password-cli" # 1Password manager CLI
        # "cf-terraforming" # create terraform resources from CF templates
        # "docker" # Docker - Containerization tool
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
        # Python
        "python" # Python Programming Language
        "virtualenv" # Virtual environment manager

        "rust" 

        # Linux like
        "bash" # Gnu Bash Shell
        "coreutils" # GNU core utilities for Mac
        "cowsay" # ASCII cow
        "gnupg" # GnuPG key management tool
        "pinentry-mac" # GPG key entry utility
        "neofetch"
        "wget"
        "p7zip"
        "pkg-config"
        "htop" # Process viewer
        "btop"
        "lf"
        "fd"

        # Utils
        "yt-dlp" # Download youtube videos
        "mpv" # Video player
        "pandoc" # Markdown converter
        "fzf" # Fuzzy finder
        "mas" # Mac appstore installer
        "borgbackup" # simple backup solution
        "hugo" # Static site generator
        "rclone" # Rsync for Cloud storage
        "iperf3" #  Network performance test
        "zoxide" # smarter cd command
        "cloudflare/cloudflare/cloudflared" # Cloudflare daemon
        "hashicorp/tap/terraform" # Terraform CLI tool for managing infrastructure
        "terraform"

        # Ansible
        "ansible" # Ansible command line tool
        "age"  # age is a simple, modern and secure file encryption tool, format, and Go library.
        "yamllint" # YAML linter
        "ansible-lint" # Ansible linter
        "hudochenkov/sshpass/sshpass" # SSHPass - SSH password manager

        # Containers
        "lazydocker" # docker TUI
        "kubernetes-cli" # Kubernetes CLI tool
        "helm"
        "kustomize"

        # Git
        "git" # Git command line tool
        "git-flow" # Better git flow
        "lazygit" # git TUI
        "gh" # GitHub CLI
        "pre-commit" # Git pre-commit hook

        # Dev utils
        "sops" # Secret key encryption
        "tmux" # Terminal multiplexer
        "tree" # Tree command line tool
        "watch" # Watch command line tool
        "jq" # JSON query tool
        "flyctl" # Fly.io tool
        ];
  };
               }
