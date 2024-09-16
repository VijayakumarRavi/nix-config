{
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
    extraConfig = ''
      # change default meta key to same as screen
      unbind C-b
      unbind C-a
      set -g prefix `

      # form vim/tmux d/y buffer sync
      set -g focus-events

      # use a different prefix for nested
      bind-key -n C-y send-prefix

      # pane colors and display
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

      set-option -g detach-on-destroy off
      bind a command-prompt -p "New Session:" "new-session -A -s '%%'"
      bind -r m switch-client -n

      # add switch windows
      unbind p
      bind p previous-window

      # kill current window and all panes
      bind-key & kill-window

      #bind C send-keys -t.- 'tmux_session_switcher' Enter

      # vi keys to resize
      bind k resize-pane -U 1
      bind j resize-pane -D 1
      bind h resize-pane -L 1
      bind l resize-pane -R 1

      # avoid cursor movement messing with resize
      set -g repeat-time 200

      # colors, clock, and stuff
      set -g clock-mode-colour cyan

      # color the pane borders nearly invisible
      # (when not using hacked tmux without them)
      set -g pane-border-style "fg=#171717"
      set -g pane-active-border-style "fg=#171717"

      # For Yazi Image Preview
      set -g allow-passthrough on
      set -ga update-environment TERM
      set -ga update-environment TERM_PROGRAM

      # color of the window selection background
      set -g mode-style "bg=black"

      # very unique Mac bug
      if-shell "type 'reattach-to-user-namespace' >/dev/null" "set -g default-command 'reattach-to-user-namespace -l $SHELL'"

      # reload configuration
      bind -r r source-file ~/.config/tmux/tmux.conf \; display-message "config reloaded"

      set -g status on
      set -g status-style "fg=#665c54"
      set -g status-bg default
      set -g status-position top
      set -g status-interval 1
      set -g status-left ""
      set -g status-right-length 50
      set -g status-right "Host: #(hostname)"
      set -g message-style "fg=red"
    '';
  };
}
