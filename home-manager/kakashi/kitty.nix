{pkgs, ...}: {
  programs.kitty = {
    enable = true;
    package = pkgs.kitty;
    font = {
      package = pkgs.jetbrains-mono;
      name = "JetBrains Mono";
    };
    #themeFile = "GruvboxMaterialDarkHard";
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
  home.file.".config/kitty/diff.conf".text = ''
    foreground #a9b1d6
    background #1a1b26

    title_fg #a9b1d6
    title_bg #1a1b26

    margin_bg #24283b
    margin_fg #565f89

    removed_bg           #3b2b3c
    highlight_removed_bg #5c3f5c
    removed_margin_bg    #4a3950

    added_bg           #283b4d
    highlight_added_bg #3d5a70
    added_margin_bg    #324a5d

    filler_bg #1f2335

    margin_filler_bg #24283b

    hunk_margin_bg #24283b
    hunk_bg        #24283b

    search_bg #3d59a1
    search_fg #c0caf5
    select_bg #33467c
    select_fg #c0caf5
  '';
}
