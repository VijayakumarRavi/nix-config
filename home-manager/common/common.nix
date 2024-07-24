{ pkgs, ... }: {
  programs = {
    zoxide = { # smarter cd command
      enable = true;
      enableZshIntegration = true;
      options = [ "--cmd cd" ];
    };
    fzf = {
      enable = true; # Fuzzy finder
      enableZshIntegration = true;
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    gh = {
      enable = true; # GitHub CLI
      extensions = with pkgs; [ gh-markdown-preview ];
      settings = {
        git_protocol = "ssh";
        prompt = "enabled";
      };
    };
    atuin = { # sync shell history between machines
      enable = true;
      enableZshIntegration = true;
      flags = [ "--disable-up-arrow" ];
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
        Host sanji
            HostName 10.0.0.3
            User pi
            Port 22
        Host nami
            HostName 10.0.0.2
            User vijay
            Port 22
            RequestTTY yes
            RemoteCommand tmux -u at -t ssh_mux || tmux -u new -s ssh_mux
        Host zoro
            HostName 10.0.0.4
            User vijay
            Port 22
            RequestTTY yes
            RemoteCommand tmux -u at -t ssh_mux || tmux -u new -s ssh_mux
      '';
    };
  };
}
