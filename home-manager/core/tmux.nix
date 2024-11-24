{pkgs, ...}: let
  isMacOS = pkgs.stdenv.system == "x86_64-darwin" || pkgs.stdenv.system == "aarch64-darwin";
in {
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    aggressiveResize = true;
    baseIndex = 1;
    historyLimit = 100000000;
    # fix accidentally typing accent characters, etc. by forcing the terminal to not wait around
    #escapeTime = 0;
    keyMode = "vi";
    mouse = false; # set to true if you like pain
    plugins = with pkgs.tmuxPlugins; [
      yank
      tmux-fzf
      {
        plugin = fzf-tmux-url;
        extraConfig = ''
          set -g @fzf-url-fzf-options '-p 60%,30% --prompt="   " --border-label=" Open URL "'
          set -g @fzf-url-history-limit '2000'
        '';
      }
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15' # minutes
        '';
      }
    ];
    extraConfig =
      /*
      tmux
      */
      ''
        # change default meta key to same as screen
        unbind C-b
        unbind C-a
        set -g prefix `

        # Options
        set -g focus-events                 # form vim/tmux d/y buffer sync
        set-option -g detach-on-destroy off # don't exit from tmux when closing a session
        set -g repeat-time 200              # avoid cursor movement messing with resize
        set -g clock-mode-colour cyan       # colors, clock, and stuff
        set -g renumber-windows on          # renumber all windows when any window is closed
        set -g set-clipboard on             # use system clipboard

        # For Yazi Image Preview
        set -g allow-passthrough on
        set -ga update-environment TERM
        set -ga update-environment TERM_PROGRAM

        # color the pane borders nearly invisible
        # (when not using hacked tmux without them)
        set -g pane-border-style "fg=#171717"
        set -g pane-active-border-style "fg=#171717"

        # color of the window selection background
        set -g mode-style "bg=black"

        # very unique Mac bug
        ${
          if isMacOS
          then ''
            if-shell "type '${pkgs.reattach-to-user-namespace}/bin/reattach-to-user-namespace' >/dev/null" "set -g default-command '${pkgs.reattach-to-user-namespace}/bin/reattach-to-user-namespace -l ${pkgs.zsh}/bin/zsh'"
          ''
          else ""
        }

        # status line
        set -g status on
        set -g status-style "fg=#665c54"
        set -g status-bg default
        set -g status-position top
        set -g status-interval 1
        set -g status-left ""
        set -g status-right-length 50
        set -g status-right "Host: #(hostname)"
        set -g message-style "fg=red"

        # Keybindings
        # use a different prefix for nested
        bind-key -n C-y send-prefix

        # create more intuitive split key combos (same as modern screen)
        unbind '"'
        unbind %
        unbind |
        bind | split-window -h -c "#{pane_current_path}"
        bind '\' split-window -h -c "#{pane_current_path}"
        bind 'C-\' split-window -h -c "#{pane_current_path}"
        unbind -
        bind - split-window -v -c "#{pane_current_path}"
        unbind _
        bind _ split-window -v -c "#{pane_current_path}"

        # open new windows in the current path
        bind c new-window -c "#{pane_current_path}"

        bind a command-prompt -p "New Session:" "new-session -A -s '%%'"
        bind -r m switch-client -n

        # add switch windows
        unbind p
        bind p previous-window

        # kill current window and all panes
        bind-key & kill-window

        # vi keys to resize
        bind k resize-pane -U 1
        bind j resize-pane -D 1
        bind h resize-pane -L 1
        bind l resize-pane -R 1

        # reload configuration
        bind -r r source-file ~/.config/tmux/tmux.conf \; display-message "config reloaded"
      '';
  };
}
