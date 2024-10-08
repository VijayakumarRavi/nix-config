{pkgs, ...}: {
  services = {
    # A minimal status bar for macOS
    spacebar = {
      enable = false;
      package = pkgs.spacebar;
    };
    # A tiling window manager for macOS based on binary space partitioning
    yabai = {
      enable = true;
      config = let
        padding = 10;
      in {
        layout = "bsp";
        focus_follows_mouse = "autoraise";
        mouse_follows_focus = "off";
        window_placement = "second_child";
        top_padding = padding;
        bottom_padding = padding;
        left_padding = padding;
        right_padding = padding;
        window_gap = padding;
      };
      extraConfig = ''
        yabai -m rule --add app='System Settings' manage=off
        yabai -m rule --add app='Finder' manage=off
        yabai -m rule --add app='Raycast' manage=off
        yabai -m config mouse_modifier cmd
        # Make non-resizable windows floating
        yabai -m signal --add event=window_created action='yabai -m query --windows --window $YABAI_WINDOW_ID |\
        ${pkgs.jq}/bin/jq -er ".\"can-resize\" or .\"is-floating\"" ||\
        yabai -m window $YABAI_WINDOW_ID --toggle float ||\
        yabai -m window $YABAI_WINDOW_ID --focus'
      '';
    };
    skhd = {
      enable = true;
      skhdConfig = ''
        # Create space on the active display
        ctrl + alt - n : yabai -m space --create
        # Delete focused space and focus first space on display
        ctrl + alt - d : yabai -m space --destroy
        ##############################################
        # Navigation (focussing)
        ##############################################

        # Windows: Alt + [DIR]
        alt - h : yabai -m window --focus west
        alt - j : yabai -m window --focus south
        alt - k : yabai -m window --focus north
        alt - l : yabai -m window --focus east

        # find main editor region
        alt - n : yabai -m window --focus largest

        # Spaces:  Alt + [NUM]
        alt - 1 : yabai -m space --focus 1
        alt - 2 : yabai -m space --focus 2
        alt - 3 : yabai -m space --focus 3
        alt - 4 : yabai -m space --focus 4
        alt - 5 : yabai -m space --focus 5
        alt - 6 : yabai -m space --focus 6

        # Monitors: Ctrl + Alt + [NUM]
        ctrl + alt - 1  : yabai -m display --focus 1
        ctrl + alt - 2  : yabai -m display --focus 2

        ##############################################
        # Moving
        ##############################################

        # " Swaps " with another Window, obtaining its size and position
        # Swap: Ctrl + Alt + [DIR]
        ctrl + alt - h : yabai -m window --swap west
        ctrl + alt - j : yabai -m window --swap south
        ctrl + alt - k : yabai -m window --swap north
        ctrl + alt - l : yabai -m window --swap east

        # Sends Window to Space and shifts focus
        # Send: Shift + Cmd + [NUM]
        shift + cmd - 1 : yabai -m window --space  1; yabai -m space --focus 1; sketchybar --trigger windows_on_spaces
        shift + cmd - 2 : yabai -m window --space  2; yabai -m space --focus 2; sketchybar --trigger windows_on_spaces
        shift + cmd - 3 : yabai -m window --space  3; yabai -m space --focus 3; sketchybar --trigger windows_on_spaces
        shift + cmd - 4 : yabai -m window --space  4; yabai -m space --focus 4; sketchybar --trigger windows_on_spaces
        shift + cmd - 5 : yabai -m window --space  5; yabai -m space --focus 5; sketchybar --trigger windows_on_spaces
        shift + cmd - 6 : yabai -m window --space  6; yabai -m space --focus 6; sketchybar --trigger windows_on_spaces
        shift + cmd - 7 : yabai -m window --space  7; yabai -m space --focus 7; sketchybar --trigger windows_on_spaces
        shift + cmd - 8 : yabai -m window --space  8; yabai -m space --focus 8; sketchybar --trigger windows_on_spaces

        # Sends Window to Monitor and shifts focus
        # Send Monitor: Ctrl + Cmd + [NUM]
        ctrl + cmd - 1  : yabai -m window --display 1; yabai -m display --focus 1
        ctrl + cmd - 2  : yabai -m window --display 2; yabai -m display --focus 2

        # Floating Move
        shift + ctrl - a : yabai -m window --move rel:-20:0
        shift + ctrl - s : yabai -m window --move rel:0:20
        shift + ctrl - w : yabai -m window --move rel:0:-20
        shift + ctrl - d : yabai -m window --move rel:20:0

        # Rotate
        alt - r : yabai -m space --rotate 90

        ##############################################
        # Sizing: Shift + [Alt/Cmd] + [DIR]
        ##############################################

        # Auto
        shift + alt - 0 : yabai -m space --balance

        # Increase (no decrease options, just resizing the relevant windows)
        shift + alt - a : yabai -m window --resize left:-40:0
        shift + alt - s : yabai -m window --resize bottom:0:40
        shift + alt - w : yabai -m window --resize top:0:-40
        shift + alt - d : yabai -m window --resize right:40:0

        ##############################################
        # Toggling
        ##############################################

        # Fullscreen (still includes gaps)
        alt - f : yabai -m window --toggle zoom-fullscreen;\
                  sketchybar --trigger window_focus

        shift + alt - f : yabai -m window --toggle native-fullscreen

        # Float and center
        alt - t : yabai -m window --toggle float;\
                  yabai -m window --grid 4:4:1:1:2:2;\
                  sketchybar --trigger window_focus

        # Float and right up for bilibili music
        alt - y : yabai -m window --toggle float;\
                  yabai -m window --grid 5:5:3:0:1:1;\
                  yabai -m window --move rel:-2:2;\
                  sketchybar --trigger window_focus

        # Float and right up for cava music
        alt - u : yabai -m window --toggle float;\
                  yabai -m window --grid 5:5:4:0:1:1;\
                  yabai -m window --move rel:-2:2;\
                  sketchybar --trigger window_focus
        ##############################################
        # Floating
        ##############################################

        # Fill
        shift + alt - up     : yabai -m window --grid 1:1:0:0:1:1

        # Left
        shift + alt - left   : yabai -m window --grid 1:2:0:0:1:1

        # Right
        shift + alt - right  : yabai -m window --grid 1:2:1:0:1:1

        # close
        alt - d : yabai -m window --close
      '';
    };
  };
}
