{pkgs, ...}: {
  programs.kitty = {
    enable = true;
    package = pkgs.kitty;
    font = {
      package = pkgs.jetbrains-mono;
      name = "JetBrains Mono";
    };
    # themeFile = "GruvboxMaterialDarkHard";
    # themeFile = "tokyo_night_night";
    shellIntegration.mode = "no-cursor";
    settings = {
      background_opacity = "1";
      copy_on_select = true;
      clipboard_control = "write-clipboard read-clipboard write-primary read-primary";
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";
      font_size =
        if pkgs.stdenvNoCC.isDarwin
        then 18
        else 16;
      strip_trailing_spaces = "smart";
      enable_audio_bell = "no";
      term = "xterm-256color";
      macos_titlebar_color = "background";
      hide_window_decorations = "yes";
      macos_option_as_alt = "yes";
      scrollback_lines = 999999;
      cursor_shape = "underline";
      cursor_blink_interval = 0.8;

      # Base16 Black Metal (Gorgoroth) - kitty color config
      # Scheme by metalelf0 (https://github.com/metalelf0)
      # background = "#000000";
      foreground = "#c1c1c1";
      selection_background = "#c1c1c1";
      selection_foreground = "#000000";
      url_color = "#999999";
      cursor = "#c1c1c1";
      active_border_color = "#333333";
      inactive_border_color = "#121212";
      active_tab_background = "#000000";
      active_tab_foreground = "#c1c1c1";
      inactive_tab_background = "#121212";
      inactive_tab_foreground = "#999999";
      tab_bar_background = "#121212";

      # normal
      color0 = "#000000";
      color1 = "#5f8787";
      color2 = "#9b8d7f";
      color3 = "#8c7f70";
      color4 = "#888888";
      color5 = "#999999";
      color6 = "#aaaaaa";
      color7 = "#c1c1c1";

      # bright
      color8 = "#333333";
      color9 = "#5f8787";
      color10 = "#9b8d7f";
      color11 = "#8c7f70";
      color12 = "#888888";
      color13 = "#999999";
      color14 = "#aaaaaa";
      color15 = "#c1c1c1";

      # extended base16 colors
      color16 = "#aaaaaa";
      color17 = "#444444";
      color18 = "#121212";
      color19 = "#222222";
      color20 = "#999999";
      color21 = "#999999";

      # # Everblush for Kitty
      # # Base colors
      # foreground = "#dadada";
      # background = "#141b1e";
      # selection_foreground = "#dadada";
      # selection_background = "#2d3437";
      #
      # # Cursor colors
      # cursor = "#2d3437";
      # cursor_text_color = "#dadada";
      #
      # # Normal colors
      # color0 = "#232a2d";
      # color1 = "#e57474";
      # color2 = "#8ccf7e";
      # color3 = "#e5c76b";
      # color4 = "#67b0e8";
      # color5 = "#c47fd5";
      # color6 = "#6cbfbf";
      # color7 = "#b3b9b8";
      #
      # # Bright colors
      # color8 = "#2d3437";
      # color9 = "#ef7e7e";
      # color10 = "#96d988";
      # color11 = "#f4d67a";
      # color12 = "#71baf2";
      # color13 = "#ce89df";
      # color14 = "#67cbe7";
      # color15 = "#bdc3c2";
      #
      # # Tab colors
      # active_tab_foreground = "#e182e0";
      # active_tab_background = "#1b2224";
      # inactive_tab_foreground = "#cd69cc";
      # inactive_tab_background = "#232a2c";
    };
    keybindings = {
      "ctrl+c" = "copy_or_interrupt";
      "ctrl+f>2" = "set_font_size 20";
      "cmd+t" = "new_tab !neighbor";
      "cmd+1" = "goto_tab 1";
      "cmd+2" = "goto_tab 2";
      "cmd+3" = "goto_tab 3";
      "cmd+4" = "goto_tab 4";
      "cmd+5" = "goto_tab 5";
      "cmd+6" = "goto_tab 6";
      "cmd+7" = "goto_tab 7";
      "cmd+8" = "goto_tab 8";
      "cmd+9" = "goto_tab 9";
      "cmd+0" = "goto_tab 10r";
    };
  };
}
