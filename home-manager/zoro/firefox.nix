# home.nix

{ pkgs, inputs, ... }:

{
  programs.firefox = {
    enable = true;
    profiles.vijay = {

      search.engines = {
        "Nix Packages" = {
          urls = [
          {
            template = "https://search.nixos.org/packages";
            params = [
            {
              name = "type";
              value = "packages";
            }
            {
              name = "channel";
              value = "unstable";
            }
            {
              name = "query";
              value = "{searchTerms}";
            }
            ];
          }
          ];
          icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          definedAliases = ["@n"];
        };
      };

      search.force = true;

      bookmarks = [
      {
        name = "wikipedia";
        tags = [ "wiki" ];
        keyword = "wiki";
        url = "https://en.wikipedia.org/wiki/Special:Search?search=%s&go=Go";
      }
      ];

      settings = {
        "browser.disableResetPrompt" = true;
        "browser.download.panel.shown" = true;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.shell.defaultBrowserCheckCount" = 1;
        "browser.startup.homepage" = "https://start.duckduckgo.com";

        # taken from Misterio77's config
        "browser.uiCustomization.state" = ''{"placements":{"widget-overflow-fixed-list":[],"nav-bar":["back-button","forward-button","stop-reload-button","home-button","urlbar-container","downloads-button","library-button","ublock0_raymondhill_net-browser-action","_testpilot-containers-browser-action"],"toolbar-menubar":["menubar-items"],"TabsToolbar":["tabbrowser-tabs","new-tab-button","alltabs-button"],"PersonalToolbar":["import-button","personal-bookmarks"]},"seen":["save-to-pocket-button","developer-button","ublock0_raymondhill_net-browser-action","_testpilot-containers-browser-action"],"dirtyAreaCache":["nav-bar","PersonalToolbar","toolbar-menubar","TabsToolbar","widget-overflow-fixed-list"],"currentVersion":18,"newElementCount":4}'';
        "dom.security.https_only_mode" = true;
        "identity.fxaccounts.enabled" = false;
        "privacy.trackingprotection.enabled" = true;
        "signon.rememberSignons" = false;
        "browser.newtabpage.pinned" = [
        { title = "NixOS";    url = "https://nixos.org";  }
        ];
      };

      userChrome = ''
        /* some css */
        '';

      extensions = with inputs.firefox-addons.packages."x86_64-linux"; [
        1password-x-password-manager
        aria2-integration
        enhancer-for-youtube
        dracula-dark-colorscheme
        ublock-origin
        sponsorblock
        darkreader
        multi-account-containers
        youtube-shorts-block
      ];

    };
  };
}

