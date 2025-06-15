{
  lib,
  pkgs,
  config,
  inputs,
  variables,
  ...
}: let
  fd = lib.getExe pkgs.fd;
in {
  imports = [inputs.nix-index-database.hmModules.nix-index];
  programs = {
    nix-index.enable = true;
    nix-index.enableZshIntegration = true;
    nix-index-database.comma.enable = true;

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
      config = {
        global = {
          # Hides the rather large block of text that is usually printed when entering the environment.
          hide_env_diff = true;
        };
        whitelist = {
          prefix = ["~/.nix-config"];
        };
      };
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
        Host *
          IdentityAgent "~/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock"

        Host sanji
            HostName sanji
            User ${variables.username}
            Port 22
            RequestTTY yes
            RemoteCommand tmux -u new-session -A -s ssh_mux
        Host nami
            HostName nami
            User ${variables.username}
            Port 22
            RequestTTY yes
            RemoteCommand tmux -u new-session -A -s ssh_mux
        Host zoro
            HostName zoro
            User ${variables.username}
            Port 22
            RequestTTY yes
            RemoteCommand tmux -u new-session -A -s ssh_mux
        Host usopp
            HostName usopp
            User ${variables.username}
            Port 22
            RequestTTY yes
            RemoteCommand tmux -u new-session -A -s ssh_mux
        Host chopper
            HostName chopper
            User ${variables.username}
            Port 22
            RequestTTY yes
            RemoteCommand tmux -u new-session -A -s ssh_mux
        Host robin
            HostName robin
            User ${variables.username}
            Port 69
            RequestTTY yes
            RemoteCommand tmux -u new-session -A -s ssh_mux
      '';
    };
  };
}
