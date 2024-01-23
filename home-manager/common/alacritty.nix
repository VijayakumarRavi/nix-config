{ pkgs, ... }: {
  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "xterm-256color";
      window = {
        opacity = 0.8;
        dynamic_title = true;
        dynamic_padding = true;
        decorations = "full";
        dimensions = {
          lines = 0;
          columns = 0;
        };
        padding = {
          x = 5;
          y = 5;
        };
        option_as_alt = "OnlyLeft";
      };

      scrolling = {
        history = 10000;
        multiplier = 3;
      };

      mouse = { hide_when_typing = false; };

      font = let fontname = "JetBrainsMono Nerd Font Mono";
      in {
        normal = {
          family = fontname;
          style = "Regular";
        };
        bold = {
          family = fontname;
          style = "Bold";
        };
        italic = {
          family = fontname;
          style = "Italic";
        };
        size = 18;
      };
      cursor.style = "Block";

      colors = {
        primary = {
          background = "#24273A";
          foreground = "#CAD3F5";
          dim_foreground = "#CAD3F5";
          bright_foreground = "#CAD3F5";
        };
        cursor = {
          text = "#24273A";
          cursor = "#F4DBD6";
        };
        vi_mode_cursor = {
          text = "#24273A";
          cursor = "#B7BDF8";
        };
        search.matches = {
          foreground = "#24273A";
          background = "#A5ADCB";
        };
        search.focused_match = {
          foreground = "#24273A";
          background = "#A6DA95";
        };
        footer_bar = {
          foreground = "#24273A";
          background = "#A5ADCB";
        };
        hints = {
          start = {
            foreground = "#24273A";
            background = "#EED49F";
          };
          end = {
            foreground = "#24273A";
            background = "#A5ADCB";
          };
        };
        selection = {
          text = "#24273A";
          background = "#F4DBD6";
        };
        normal = {
          black = "#494D64";
          red = "#ED8796";
          green = "#A6DA95";
          yellow = "#EED49F";
          blue = "#8AADF4";
          magenta = "#F5BDE6";
          cyan = "#8BD5CA";
          white = "#B8C0E0";
        };
        bright = {
          black = "#5B6078";
          red = "#ED8796";
          green = "#A6DA95";
          yellow = "#EED49F";
          blue = "#8AADF4";
          magenta = "#F5BDE6";
          cyan = "#8BD5CA";
          white = "#A5ADCB";
        };
        dim = {
          black = "#494D64";
          red = "#ED8796";
          green = "#A6DA95";
          yellow = "#EED49F";
          blue = "#8AADF4";
          magenta = "#F5BDE6";
          cyan = "#8BD5CA";
          white = "#B8C0E0";
        };
      };
    };
  };
}
