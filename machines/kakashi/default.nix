{ pkgs, ... }:
{
  imports = [
    ./homebrew.nix
    ../common
  ];

  nix = {
    configureBuildUsers = true;
    gc = {
      automatic = true;
      interval = {
        Hour = 3;
        Minute = 15;
        Weekday = 7;
      };
      options = "--delete-old";
    };
  };

  environment = {
    systemPath = [ "/opt/homebrew/bin" ];
    pathsToLink = [ "/Applications" ];
    systemPackages = with pkgs; [
      flyctl # fly.io cli tool
      vscode # Visual Studio Code editor
      nodejs_22 # Node js version 22
      bitwarden-cli # free password manager

      # Mac only apps
      mas # Mac appstore installer
      stats # System monitor for the menu bar
      raycast # Raycast - A better alternative to Alfred and spotlight
      appcleaner # Application uninstaller
      pinentry_mac # GPG key entry utility
    ];
  };

  services = {
    nix-daemon.enable = true;
    # A minimal status bar for macOS
    spacebar = {
      enable = true;
      package = pkgs.spacebar;
    };
    # A tiling window manager for macOS based on binary space partitioning
    yabai = {
      enable = true;
      config =
        let
          padding = 10;
        in
        {
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
        yabai -m rule --add app='krisp' manage=off
        yabai -m rule --add app='Leapp' manage=off
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
      skhdConfig = "
        # Move focus between windows
        shift + ctrl - h : yabai -m window --focus west
        shift + ctrl - j : yabai -m window --focus south
        shift + ctrl - k : yabai -m window --focus north
        shift + ctrl - l : yabai -m window --focus east

        # Move windows around
        shift + alt - h : yabai -m window --swap west
        shift + alt - j : yabai -m window --swap south
        shift + alt - k : yabai -m window --swap north
        shift + alt - l : yabai -m window --swap east

        shift + alt - r : yabai -m space --rotate 90
      ";
    };
  };

  # Logging is disabled by default
  launchd.user.agents.skhd.serviceConfig = {
    StandardOutPath = "/tmp/skhd.out.log";
    StandardErrorPath = "/tmp/skhd.error.log";
  };

  networking = {
    computerName = "kakashi";
    hostName = "kakashi";
  };

  users.users.vijay = {
    home = /Users/vijay;
  };

  fonts.packages = [
    (pkgs.nerdfonts.override {
      fonts = [
        "FiraCode"
        "JetBrainsMono"
      ];
    })
  ];

  security.pam.enableSudoTouchIdAuth = true;

  # here go the darwin preferences and config items
  system = {
    keyboard.enableKeyMapping = true;
    # keyboard.remapCapsLockToEscape = true;
    defaults = {
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
      NSGlobalDomain = {
        # Auto hide the menubar
        _HIHideMenuBar = false;

        # Enable Derk mode
        AppleInterfaceStyle = "Dark";

        # Enable full keyboard access for all controls
        AppleKeyboardUIMode = 3;

        # Enable press-and-hold repeating
        ApplePressAndHoldEnabled = true;
        InitialKeyRepeat = 20;
        KeyRepeat = 1;

        # Disable "Natural" scrolling
        "com.apple.swipescrolldirection" = true;
        AppleEnableMouseSwipeNavigateWithScrolls = true;

        # Disable smart dash/period/quote substitutions
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;

        # Disable automatic capitalization
        NSAutomaticCapitalizationEnabled = false;

        # Using expanded "save panel" by default
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;

        # Increase window resize speed for Cocoa applications
        NSWindowResizeTime = 1.0e-3;

        # Save to disk (not to iCloud) by default
        NSDocumentSaveNewDocumentsToCloud = true;
      };
      dock = {
        # Set icon size and dock orientation
        tilesize = 48;
        orientation = "bottom";

        # minimize windows into their application icon
        minimize-to-application = true;

        magnification = true;
        largesize = 80;

        # Set dock to auto-hide, and transparentize icons of hidden apps (⌘H)
        autohide = true;
        showhidden = true;

        # Disable to show recents, and light-dot of running apps
        show-recents = false;
        show-process-indicators = true;

        # Hot corner
        wvous-tl-corner = 2; # Mission Control
        wvous-tr-corner = 12; # Notification Center
        wvous-bl-corner = 11; # Launchpad
        wvous-br-corner = 4; # Show Desktop

        # persistent apps in dock
        persistent-apps = [
          "/System/Applications/Launchpad.app/"
          "/Applications/Arc.app/"
          "/System/Cryptexes/App/System/Applications/Safari.app/"
          "/System/Applications/Messages.app/"
          "/System/Applications/Mail.app/"
          "/System/Applications/Music.app/"
          "/System/Applications/Photos.app/"
          "/System/Applications/System Settings.app/"
          "${pkgs.wezterm}/Applications/WezTerm.app/"
        ];
      };

      finder = {
        # Allow quitting via ⌘Q
        QuitMenuItem = false;

        # Disable warning when changing a file extension
        FXEnableExtensionChangeWarning = false;

        _FXShowPosixPathInTitle = true;

        # Show all files and their extensions
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;

        # Show path bar, and layout as multi-column
        ShowPathbar = true;
        ShowStatusBar = true; # show status bar
        FXPreferredViewStyle = "clmv";

        # Search in current folder by default
        FXDefaultSearchScope = "SCcf";
      };

      trackpad = {
        # Enable trackpad tap to click
        Clicking = true;

        # Enable 3-finger drag
        TrackpadThreeFingerDrag = false;
      };

      loginwindow = {
        GuestEnabled = true;
        LoginwindowText = "Vanakkam da mapla 👻";
      };

      ActivityMonitor = {
        # Sort by CPU usage
        SortColumn = "CPUUsage";
        SortDirection = 0;
      };

      LaunchServices = {
        # Disable quarantine for downloaded apps
        LSQuarantine = false;
      };

      CustomSystemPreferences = {
        NSGlobalDomain = {
          # Set the system accent color, TODO: https://github.com/LnL7/nix-darwin/pull/230
          AppleAccentColor = 6;
          # Jump to the spot that's clicked on the scroll bar, TODO: https://github.com/LnL7/nix-darwin/pull/672
          AppleScrollerPagingBehavior = true;
          # Prefer tabs when opening documents, TODO: https://github.com/LnL7/nix-darwin/pull/673
          AppleWindowTabbingMode = "always";
        };
        "com.apple.finder" = {
          # Keep the desktop clean
          ShowHardDrivesOnDesktop = false;
          ShowRemovableMediaOnDesktop = false;
          ShowExternalHardDrivesOnDesktop = false;
          ShowMountedServersOnDesktop = false;

          # Show directories first
          _FXSortFoldersFirst = true; # TODO: https://github.com/LnL7/nix-darwin/pull/594

          # New window use the $HOME path
          NewWindowTarget = "PfHm";
          NewWindowTargetPath = "file://$HOME/";

          # Allow text selection in Quick Look
          QLEnableTextSelection = true;
        };
        "com.apple.Safari" = {
          # For better privacy
          UniversalSearchEnabled = false;
          SuppressSearchSuggestions = true;
          SendDoNotTrackHTTPHeader = true;

          # Disable auto open safe downloads
          AutoOpenSafeDownloads = false;

          # Enable Develop Menu, Web Inspector
          IncludeDevelopMenu = true;
          IncludeInternalDebugMenu = true;
          WebKitDeveloperExtras = true;
          WebKitDeveloperExtrasEnabledPreferenceKey = true;
          "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" = true;
        };
        "com.apple.universalaccess" = {
          # Set the cursor size, TODO: https://github.com/LnL7/nix-darwin/pull/671
          mouseDriverCursorSize = 1.5;
        };
        "com.apple.screencapture" = {
          # Set the filename which screencaptures should be written, TODO: https://github.com/LnL7/nix-darwin/pull/670
          name = "screenshot";
          include-date = false;
        };
        "com.apple.desktopservices" = {
          # Avoid creating .DS_Store files on USB or network volumes
          DSDontWriteUSBStores = true;
          DSDontWriteNetworkStores = true;
        };
        "com.apple.frameworks.diskimages" = {
          # Disable disk image verification
          skip-verify = true;
          skip-verify-locked = true;
          skip-verify-remote = true;
        };
        "com.apple.CrashReporter" = {
          # Disable crash reporter
          DialogType = "none";
        };
        "com.apple.AdLib" = {
          # Disable personalized advertising
          forceLimitAdTracking = true;
          allowApplePersonalizedAdvertising = false;
          allowIdentifierForAdvertising = false;
        };
      };
    };
    activationScripts.setting.text = ''
      # Unpin all apps, TODO: https://github.com/LnL7/nix-darwin/pull/619
      defaults write com.apple.dock persistent-apps -array ""

      # Show metadata info, but not preview in info panel
      defaults write com.apple.finder FXInfoPanesExpanded -dict MetaData -bool true Preview -bool false

      # Allow opening apps from any source
      sudo spctl --master-disable

      # Change the default apps
      duti -s com.microsoft.VSCode .txt all
      duti -s com.microsoft.VSCode .ass all
      duti -s io.mpv .mkv all
      duti -s com.colliderli.iina .mp4 all

      ~/.config/os/darwin/power.sh
    '';

    # Fully declarative dock using the latest from Nix Store
    #    local = {
    #      dock.enable = true;
    #      dock.entries = [
    #        { path = "/System/Applications/Launchpad.app/"; }
    #        { path = "/Applications/Arc.app/"; }
    #        { path = "/System/Cryptexes/App/System/Applications/Safari.app/"; }
    #        { path = "/System/Applications/Messages.app/"; }
    #        { path = "/System/Applications/Mail.app/"; }
    #        { path = "/System/Applications/Music.app/"; }
    #        { path = "${pkgs.spotify}/Applications/Spotify.app/"; }
    #        { path = "/System/Applications/Photos.app/"; }
    #        { path = "/System/Applications/System Settings.app/"; }
    #        { path = "/Applications/iTerm.app/"; }
    #      ];
    #    };
    # backwards compat; don't change
    stateVersion = 4;
  };
}
