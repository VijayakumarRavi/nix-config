{pkgs, ...}: {
  home.packages = with pkgs; [aerospace sketchybar jankyborders];
  xdg.configFile."aerospace/aerospace.toml".text =
    /*
    toml
    */
    ''
      after-startup-command = ['exec-and-forget sketchybar']

      # Notify Sketchybar about workspace change
      exec-on-workspace-change = ['/bin/bash', '-c',
        'exec-and-forget borders active_color=0xffe1e3e4 inactive_color=0xff494d64 width=5.0'
      ]

      # Start AeroSpace at login
      start-at-login = false

      # Normalizations. See: https://nikitabobko.github.io/AeroSpace/guide#normalization
      enable-normalization-flatten-containers = true
      enable-normalization-opposite-orientation-for-nested-containers = true

      # See: https://nikitabobko.github.io/AeroSpace/guide#layouts
      # The 'accordion-padding' specifies the size of accordion padding
      # You can set 0 to disable the padding feature
      accordion-padding = 300

      # Possible values: tiles|accordion
      default-root-container-layout = 'tiles'

      # Possible values: horizontal|vertical|auto
      # 'auto' means: wide monitor (anything wider than high) gets horizontal orientation,
      #               tall monitor (anything higher than wide) gets vertical orientation
      default-root-container-orientation = 'auto'

      # Mouse follows focus when focused monitor changes
      # Drop it from your config, if you don't like this behavior
      # See https://nikitabobko.github.io/AeroSpace/guide#on-focus-changed-callbacks
      # See https://nikitabobko.github.io/AeroSpace/commands#move-mouse
      # Fallback value (if you omit the key): on-focused-monitor-changed = []
      on-focused-monitor-changed = ['move-mouse monitor-lazy-center']

      # You can effectively turn off macOS "Hide application" (cmd-h) feature by toggling this flag
      # Useful if you don't use this macOS feature, but accidentally hit cmd-h or cmd-alt-h key
      # Also see: https://nikitabobko.github.io/AeroSpace/goodness#disable-hide-app
      automatically-unhide-macos-hidden-apps = false

      # [[on-window-detected]]
      # if.app-id = 'com.apple.systempreferences'
      # if.app-name-regex-substring = 'settings'
      # if.window-title-regex-substring = 'substring'
      # if.workspace = 'workspace-name'
      # if.during-aerospace-startup = true
      # check-further-callbacks = true
      # run = ['layout floating', 'move-node-to-workspace S']  # The callback itself

      [[on-window-detected]]
      if.app-name-regex-substring = 'settings'
      run = 'layout floating'

      [[on-window-detected]]
      if.app-name-regex-substring = 'finder'
      run = 'layout floating'

      # Possible values: (qwerty|dvorak)
      # See https://nikitabobko.github.io/AeroSpace/guide#key-mapping
      [key-mapping]
      preset = 'qwerty'

      # Gaps between windows (inner-*) and between monitor edges (outer-*).
      # Possible values:
      # - Constant:     gaps.outer.top = 8
      # - Per monitor:  gaps.outer.top = [{ monitor.main = 16 }, { monitor."some-pattern" = 32 }, 24]
      #                 In this example, 24 is a default value when there is no match.
      #                 Monitor pattern is the same as for 'workspace-to-monitor-force-assignment'.
      #                 See: https://nikitabobko.github.io/AeroSpace/guide#assign-workspaces-to-monitors
      [gaps]
      inner.horizontal = 8
      inner.vertical   = 8
      outer.left       = 8
      outer.bottom     = 8
      outer.top        = 8
      outer.right      = 8

      # 'main' binding mode declaration
      # See: https://nikitabobko.github.io/AeroSpace/guide#binding-modes
      # 'main' binding mode must be always presented
      # Fallback value (if you omit the key): mode.main.binding = {}
      [mode.main.binding]

      # All possible keys:
      # - Letters.        a, b, c, ..., z
      # - Numbers.        0, 1, 2, ..., 9
      # - Keypad numbers. keypad0, keypad1, keypad2, ..., keypad9
      # - F-keys.         f1, f2, ..., f20
      # - Special keys.   minus, equal, period, comma, slash, backslash, quote, semicolon, backtick,
      #                   leftSquareBracket, rightSquareBracket, space, enter, esc, backspace, tab
      # - Keypad special. keypadClear, keypadDecimalMark, keypadDivide, keypadEnter, keypadEqual,
      #                   keypadMinus, keypadMultiply, keypadPlus
      # - Arrows.         left, down, up, right

      # All possible modifiers: cmd, alt, ctrl, shift

      # All possible commands: https://nikitabobko.github.io/AeroSpace/commands

      # See: https://nikitabobko.github.io/AeroSpace/commands#exec-and-forget
      # You can uncomment the following lines to open up terminal with alt + enter shortcut (like in i3)
      # alt-enter = '''exec-and-forget sascript -e '
      # tell application "Terminal"
      #     do script
      #     activate
      # end tell'
      # '''

      alt-ctrl-shift-f = 'fullscreen'
      alt-ctrl-f = 'layout floating'
      alt-shift-c = 'reload-config'

      alt-shift-left = 'join-with left'
      alt-shift-down = 'join-with down'
      alt-shift-up = 'join-with up'
      alt-shift-right = 'join-with right'

      # See: https://nikitabobko.github.io/AeroSpace/commands#layout
      alt-slash = 'layout tiles horizontal vertical'
      alt-comma = 'layout accordion horizontal vertical'

      # See: https://nikitabobko.github.io/AeroSpace/commands#focus
      alt-h = 'focus left'
      alt-j = 'focus down'
      alt-k = 'focus up'
      alt-l = 'focus right'

      # See: https://nikitabobko.github.io/AeroSpace/commands#move
      alt-shift-h = 'move left'
      alt-shift-j = 'move down'
      alt-shift-k = 'move up'
      alt-shift-l = 'move right'

      # See: https://nikitabobko.github.io/AeroSpace/commands#resize
      alt-shift-minus = 'resize smart -50'
      alt-shift-equal = 'resize smart +50'

      # See: https://nikitabobko.github.io/AeroSpace/commands#workspace
      alt-1 = 'workspace 1'
      alt-2 = 'workspace 2'
      alt-3 = 'workspace 3'
      alt-4 = 'workspace 4'
      alt-5 = 'workspace 5'
      alt-6 = 'workspace 6'
      alt-7 = 'workspace 7'
      alt-8 = 'workspace 8'
      alt-9 = 'workspace 9'

      # See: https://nikitabobko.github.io/AeroSpace/commands#move-node-to-workspace
      alt-shift-1 = 'move-node-to-workspace 1' # --focus-follows-window'
      alt-shift-2 = 'move-node-to-workspace 2' # --focus-follows-window'
      alt-shift-3 = 'move-node-to-workspace 3' # --focus-follows-window'
      alt-shift-4 = 'move-node-to-workspace 4' # --focus-follows-window'
      alt-shift-5 = 'move-node-to-workspace 5' # --focus-follows-window'
      alt-shift-6 = 'move-node-to-workspace 6' # --focus-follows-window'
      alt-shift-7 = 'move-node-to-workspace 7' # --focus-follows-window'
      alt-shift-8 = 'move-node-to-workspace 8' # --focus-follows-window'
      alt-shift-9 = 'move-node-to-workspace 9' # --focus-follows-window'

      # alt-tab = 'workspace-back-and-forth'
      # alt-shift-tab = 'move-workspace-to-monitor --wrap-around next'

      # See: https://nikitabobko.github.io/AeroSpace/commands#mode
      alt-s = 'mode service'
      alt-a = 'mode apps'

      # 'service' binding mode declaration.
      # See: https://nikitabobko.github.io/AeroSpace/guide#binding-modes
      [mode.service.binding]
      esc = ['reload-config', 'mode main']
      r = ['flatten-workspace-tree', 'mode main'] # reset layout
      f = ['layout floating tiling', 'mode main'] # Toggle between floating and tiling layout
      backspace = ['close-all-windows-but-current', 'mode main']

      [mode.apps.binding]
      f = ['exec-and-forget open -a finder', 'mode main']
      a = ['exec-and-forget open -a /Applications/Arc.app', 'mode main']
      z = ['exec-and-forget open -a /Applications/Zen Browser.app', 'mode main']
      m = ['exec-and-forget open -a /System/Applications/Music.app', 'mode main']
      s = ['exec-and-forget open -a /System/Applications/System Settings.app', 'mode main']
      b = ['exec-and-forget open -a /Applications/Bitwarden.app', 'mode main']
      i = ['exec-and-forget open -a /System/Applications/iPhone Mirroring.app', 'mode main']
      o = ['exec-and-forget open -a /Applications/Omnivore.app', 'mode main']
      enter = ['exec-and-forget open -n ${pkgs.wezterm}/Applications/wezterm.app', 'mode main']
    '';
}