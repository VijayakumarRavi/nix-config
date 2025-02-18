{
  pkgs,
  inputs,
  variables,
  ...
}: {
  imports = [
    ../core
    ./homebrew.nix
    ./launchDaemons.nix
    inputs.sops-nix.darwinModules.sops
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

  ids.gids.nixbld = 350;

  environment = {
    pathsToLink = ["/Applications"];
    systemPath = ["/opt/homebrew/bin"];
    systemPackages = with pkgs; [obsidian];
  };

  services.nix-daemon.enable = true;

  sops = {
    defaultSopsFile = ../../secrets.yaml;
    validateSopsFiles = false;

    age = {
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };

    secrets = {
      "kakashi.yaml" = {};
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
    dns = ["127.0.0.1"];
    knownNetworkServices = [
      "USB 10/100 LAN"
      "Wi-Fi"
      "iPhone USB"
      "Thunderbolt Bridge"
      "Tailscale"
    ];
  };

  users.users.${variables.username} = {
    home = /Users/${variables.username};
  };

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
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

        "com.apple.keyboard.fnState" = true;
        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.trackpad.enableSecondaryClick" = true;

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

        # Move windows by dragging any part of the window
        NSWindowShouldDragOnGesture = true;

        # Disable windows opening animations
        NSAutomaticWindowAnimationsEnabled = false;
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
          "/Applications/Zen Browser.app/"
          "/System/Cryptexes/App/System/Applications/Safari.app/"
          "/System/Applications/Messages.app/"
          "/System/Applications/Mail.app/"
          "/System/Applications/Music.app/"
          "/System/Applications/Photos.app/"
          "/System/Applications/System Settings.app/"
          "${pkgs.wezterm}/Applications/wezterm.app/"
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
    '';
    # backwards compat; don't change
    stateVersion = variables.stateVersionDarwin;
  };
}
