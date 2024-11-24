{pkgs, ...}: {
  programs.kitty = {
    enable = false;
    package = pkgs.kitty;
    font = {
      package = pkgs.jetbrains-mono;
      name = "JetBrains Mono";
    };
    # themeFile = "GruvboxMaterialDarkHard";
    themeFile = "tokyo_night_night";
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
