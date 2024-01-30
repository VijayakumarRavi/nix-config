{ pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    profiles.vijay = {

      search.engines = {
        "Nix Packages" = {
          urls = [{
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
          }];
          icon =
            "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          definedAliases = [ "@ni" ];
        };
        "Home manager options" = {
          urls = [{
            template = "https://mipmip.github.io/home-manager-option-search/";
            params = [{
              name = "query";
              value = "{searchTerms}";
            }];
          }];
          icon =
            "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          definedAliases = [ "@ho" ];
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
        {
          name = "kernel.org";
          url = "https://www.kernel.org";
        }

        {
          name = "Nix sites";
          toolbar = true;
          bookmarks = [
            {
              name = "homepage";
              url = "https://nixos.org/";
            }
            {
              name = "wiki";
              tags = [ "wiki" "nix" ];
              url = "https://nixos.wiki/";
            }
            {
              name = "Home manager search";
              url = "https://mipmip.github.io/home-manager-option-search/";
            }
          ];
        }
      ];

      settings = {
        "browser.disableResetPrompt" = true;
        "browser.download.panel.shown" = true;
        "extensions.pocket.enabled" = false;
        "browser.urlbar.suggest.pocket" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.shell.defaultBrowserCheckCount" = 1;
        "browser.startup.homepage" = "https://homer-vijay.vercel.app/";

        "browser.newtabpage.activity-stream.discoverystream.enabled" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;

        # taken from Misterio77's config
        "browser.uiCustomization.state" = ''
          {"placements":{"widget-overflow-fixed-list":[],"nav-bar":["back-button","forward-button","stop-reload-button","home-button","urlbar-container","downloads-button","library-button","ublock0_raymondhill_net-browser-action","_testpilot-containers-browser-action"],"toolbar-menubar":["menubar-items"],"TabsToolbar":["tabbrowser-tabs","new-tab-button","alltabs-button"],"PersonalToolbar":["import-button","personal-bookmarks"]},"seen":["save-to-pocket-button","developer-button","ublock0_raymondhill_net-browser-action","_testpilot-containers-browser-action"],"dirtyAreaCache":["nav-bar","PersonalToolbar","toolbar-menubar","TabsToolbar","widget-overflow-fixed-list"],"currentVersion":18,"newElementCount":4}'';
        "dom.security.https_only_mode" = true;
        "identity.fxaccounts.enabled" = false;
        "privacy.trackingprotection.enabled" = true;
        "signon.rememberSignons" = false;
        "browser.newtabpage.pinned" = [
          {
            title = "Home";
            url = "https://homer-vijay.vercel.app/";
          }
          {
            title = "NixOS";
            url = "https://nixos.org";
          }
        ];
      };

      userChrome = "\n\n\n";
    };
  };
}
