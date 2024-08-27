{pkgs, ...}: {
  programs.kitty = {
    enable = true;
    package = pkgs.kitty;
    font = {
      package = pkgs.jetbrains-mono;
      name = "JetBrains Mono";
    };
    #theme = "Gruvbox Material Dark Hard";
    theme = "Tokyo Night";
    shellIntegration.mode = "no-cursor";
    settings = {
      background_opacity = "0.8";
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
      cursor_shape = "block";
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