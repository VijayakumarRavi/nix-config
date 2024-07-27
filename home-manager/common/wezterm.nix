{ ... }:
{
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    # coolnight colorscheme:
    colorSchemes = {
      coolnight = {
        foreground = "#CBE0F0";
        background = "#011423";
        cursor_bg = "#47FF9C";
        cursor_border = "#47FF9C";
        cursor_fg = "#011423";
        selection_bg = "#033259";
        selection_fg = "#CBE0F0";
        ansi = [
          "#214969"
          "#E52E2E"
          "#44FFB1"
          "#FFE073"
          "#0FC5ED"
          "#a277ff"
          "#24EAF7"
          "#24EAF7"
        ];
        brights = [
          "#214969"
          "#E52E2E"
          "#44FFB1"
          "#FFE073"
          "#A277FF"
          "#a277ff"
          "#24EAF7"
          "#24EAF7"
        ];
      };
    };
    extraConfig = ''
      -- Pull in the wezterm API
      local wezterm = require 'wezterm'

      -- This will hold the configuration.
      local config = wezterm.config_builder()

      -- This is where you actually apply your config choices

      -- For example, changing the color scheme:
      config.color_scheme = 'coolnight'
      config.font = wezterm.font("JetBrainsMono Nerd Font")
      config.font_size = 19.0

      config.skip_close_confirmation_for_processes_named = {
        'bash',
        'sh',
        'zsh',
        'fish',
        'tmux',
      }

      -- Tab bar settings
      config.enable_tab_bar = true
      config.hide_tab_bar_if_only_one_tab = true
      config.use_fancy_tab_bar = true
      config.show_tabs_in_tab_bar = true
      config.show_new_tab_button_in_tab_bar = false
      config.window_decorations = "RESIZE"

      config.window_background_opacity = 0.8
      config.macos_window_background_blur = 10
      -- and finally, return the configuration to wezterm
      return config
    '';
  };
}
