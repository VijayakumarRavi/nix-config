{
  lib,
  pkgs,
  config,
  variables,
  ...
}: let
  fd = lib.getExe pkgs.fd;
in {
  programs = {
    htop.enable = true;

    zoxide = {
      # smarter cd command
      enable = true;
      enableZshIntegration = true;
      options = ["--cmd cd"];
    };

    fzf = rec {
      enable = true; # Fuzzy finder
      enableZshIntegration = true;
      defaultCommand = "${fd} -H --type f";
      defaultOptions = ["--height 50%"];
      fileWidgetCommand = "${defaultCommand}";
      fileWidgetOptions = ["--preview '${lib.getExe pkgs.bat} --color=always --plain --line-range=:200 {}'"];
      changeDirWidgetCommand = "${fd} -H --type d";
      changeDirWidgetOptions = ["--preview '${pkgs.tree}/bin/tree -C {} | head -200'"];
      historyWidgetOptions = [];
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
      stdlib = ''
        # stolen from @i077; store .direnv in cache instead of project dir
        declare -A direnv_layout_dirs
        direnv_layout_dir() {
            echo "''${direnv_layout_dirs[$PWD]:=$(
                echo -n "${config.xdg.cacheHome}"/direnv/layouts/
                echo -n "$PWD" | shasum | cut -d ' ' -f 1
            )}"
        }
      '';
    };

    atuin = {
      # sync shell history between machines
      enable = true;
      enableZshIntegration = true;
      flags = ["--disable-up-arrow"];
      settings = {
        auto_sync = true;
        sync_frequency = "0";
        enter_accept = false;
        invert = true;
        inline_height = "8";
        style = "compact";
      };
    };

    ssh = {
      enable = true;
      extraConfig = ''
        Host unlock-zoro
          Hostname 10.0.0.4
          Port 22
          User root
          RemoteCommand /bin/cryptsetup-askpass
        Host sanji
            HostName 10.0.0.3
            User ${variables.username}
            Port 22
            RequestTTY yes
            RemoteCommand tmux -u new-session -A -s ssh_mux
        Host nami
            HostName 10.0.0.2
            User ${variables.username}
            Port 22
            RequestTTY yes
            RemoteCommand tmux -u new-session -A -s ssh_mux
        Host zoro
            HostName 10.0.1.101
            User ${variables.username}
            Port 22
            RequestTTY yes
            RemoteCommand tmux -u new-session -A -s ssh_mux
        Host usopp
            HostName 10.0.1.102
            User ${variables.username}
            Port 22
            RequestTTY yes
            RemoteCommand tmux -u new-session -A -s ssh_mux
      '';
    };
  };
}
