{ pkgs, ... }: {
    programs.tmux = {
        enable = true;
        terminal = "tmux-256color";
        aggressiveResize = true;
        baseIndex = 1;
        historyLimit = 100000000;  
        escapeTime = 0;             # fix accidently typing accent characters, etc. by forcing the terminal to not wait around
        keyMode = "vi";
        mouse = false; # set to true if you like pain
        newSession = true;
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
            bind C-k resize-pane -U 1
            bind C-j resize-pane -D 1
            bind C-h resize-pane -L 1
            bind C-l resize-pane -R 1

            # vi keys to navigate panes
            bind -r k select-pane -U
            bind -r j select-pane -D
            bind -r h select-pane -L
            bind -r l select-pane -R

            # avoid cursor movement messing with resize
            set -g repeat-time 200

            # colors, clock, and stuff
            setw -g clock-mode-colour cyan

            # color the pane borders nearly invisible
            # (when not using hacked tmux without them)
            set -g pane-border-style "fg=#171717"
            set -g pane-active-border-style "fg=#171717"

            # color of the window selection background
            set -g mode-style "bg=black"

            # very unique Mac bug
            if-shell "type 'reattach-to-user-namespace' >/dev/null" "set -g default-command 'reattach-to-user-namespace -l $SHELL'"

            # reload configuration
            bind -r r source-file ~/.config/tmux/tmux.conf \; display-message "config reloaded"

            set -g status-style "fg=#665c54"
            set -g status-bg default
            set -g status-position top
            set -g status-interval 1
            set -g status-left ""
        
            set -g status-right-length 50
            set -g status-right "#(z pomo)"
            set -g status-right '#(gitmux "#{pane_current_path}")'

            set -g message-style "fg=red"

            set -g status on
        '';
    };
}
