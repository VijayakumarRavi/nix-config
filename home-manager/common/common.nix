{
  programs = {
    zoxide = {
      # smarter cd command
      enable = true;
      enableZshIntegration = true;
      options = [ "--cmd cd" ];
    };

    fzf = {
      enable = true; # Fuzzy finder
      enableZshIntegration = true;
    };

    atuin = {
      # sync shell history between machines
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
        Host unlock-zoro
          Hostname 10.0.0.4
          Port 22
          User root
          RemoteCommand /bin/cryptsetup-askpass
        Host sanji
            HostName 10.0.0.3
            User vijay
            Port 22
            RequestTTY yes
            RemoteCommand tmux -u new-session -A -s ssh_mux
        Host nami
            HostName 10.0.0.2
            User vijay
            Port 22
            RequestTTY yes
            RemoteCommand tmux -u new-session -A -s ssh_mux
        Host robin
            HostName robin
            User root
            Port 22
            RequestTTY yes
            RemoteCommand tmux -u new-session -A -s ssh_mux
        Host zoro
            HostName 10.0.0.4
            User vijay
            Port 22
            RequestTTY yes
            RemoteCommand tmux -u new-session -A -s ssh_mux
      '';
    };
  };
}
