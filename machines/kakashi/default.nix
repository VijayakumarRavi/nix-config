{ pkgs, ... }: {
  imports = [ ./homebrew.nix ../common ];

  environment = {
    systemPath = [ "/opt/homebrew/bin" ];
    pathsToLink = [ "/Applications" ];
  };
  nix = {
    configureBuildUsers = true;
    gc.interval = {
      Weekday = 0;
      Hour = 2;
      Minute = 0;
    };
  };

  users.users.vijay.home = /Users/vijay;
  # here go the darwin preferences and config items
  system.keyboard.enableKeyMapping = true;
  #  system.keyboard.remapCapsLockToEscape = true;
  fonts.fontDir.enable = true; # DANGER
  fonts.fonts =
    [ (pkgs.nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; }) ];
  services.nix-daemon.enable = true;
  security.pam.enableSudoTouchIdAuth = true;

  system.defaults = {
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
      InitialKeyRepeat = 10;
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
      # Set dock to auto-hide, and transparentize icons of hidden apps (⌘H)
      autohide = true;
      showhidden = true;

      # Disable to show recents, and light-dot of running apps
      show-recents = false;
      show-process-indicators = true;
    };

    finder = {
      # Allow quitting via ⌘Q
      QuitMenuItem = true;

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
        _FXSortFoldersFirst =
          true; # TODO: https://github.com/LnL7/nix-darwin/pull/594

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
        "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" =
          true;
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

  system.activationScripts.setting.text = ''
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
  # backwards compat; don't change
  system.stateVersion = 4;
}
