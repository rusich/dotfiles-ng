{
  config,
  pkgs,
  inputs,
  userConfig,
  ...
}:

{
  programs.firefox = {
    enable = true;

    profiles.${config.home.username} = {
      settings = {
        "dom.security.https_only_mode" = true;
        "browser.translations.enable" = false;
        "signon.rememberSignons" = false;
        "browser.places.importBookmarksHTML" = true;
        "browser.bookmarks.autoExportHTML" = true;
        "browser.bookmarks.file" = "/home/${userConfig.username}/Nextcloud/Configs/bookmarks.html";
        # Look'n'feel
        "sidebar.verticalTabs" = true;
        "browser.toolbars.bookmarks.visibility" = "never";
        "identity.fxaccounts.enabled" = false;
      };

      extensions = {
        force = true;
        packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
          keepassxc-browser
          simple-translate
        ];
      };

      search = {
        force = true;
        default = "ddg";
        order = [
          "ddg"
          "google"
        ];
        engines = {
          "Amazon.ca".metaData.alias = "@a";
          "bing".metaData.hidden = true;
          "ebay".metaData.hidden = true;
          "google".metaData.alias = "@g";
          "wikipedia".metaData.alias = "@w";

          "GitHub" = {
            urls = [
              {
                template = "https://github.com/search";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.fetchurl {
              url = "https://github.githubassets.com/favicons/favicon.svg";
              sha256 = "sha256-apV3zU9/prdb3hAlr4W5ROndE4g3O1XMum6fgKwurmA=";
            }}";
            definedAliases = [ "@gh" ];
          };

          "Nix Packages" = {
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "channel";
                    value = "25.11";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };

          "Nix Options" = {
            urls = [
              {
                template = "https://search.nixos.org/options";
                params = [
                  {
                    name = "channel";
                    value = "25.11";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@no" ];
          };

          "NixOS Wiki" = {
            urls = [
              {
                template = "https://nixos.wiki/index.php";
                params = [
                  {
                    name = "search";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@nw" ];
          };

          "Nixpkgs Issues" = {
            urls = [
              {
                template = "https://github.com/NixOS/nixpkgs/issues";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@ni" ];
          };

          "MyNixOS" = {
            urls = [
              {
                template = "https://mynixos.com/search";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@ny" ];
          };

          "Nixhub" = {
            urls = [ { template = "https://www.nixhub.io/packages/"; } ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@nh" ];
          };

          "HM options" = {
            urls = [
              {
                template = "https://home-manager-options.extranix.com/";
                params = [
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@nm" ];
          };

          "Nix func" = {
            urls = [
              {
                template = "https://noogle.dev/q";
                params = [
                  {
                    name = "term";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@nf" ];
          };

          # A good way to find genuine discussion
          "reddit" = {
            urls = [
              {
                template = "https://www.reddit.com/search";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.fetchurl {
              url = "https://www.redditstatic.com/accountmanager/favicon/favicon-512x512.png";
              sha256 = "sha256-4zWTcHuL1SEKk8KyVFsOKYPbM4rc7WNa9KrGhK4dJyg=";
            }}";
            definedAliases = [ "@r" ];
          };

          "Youtube" = {
            urls = [
              {
                template = "https://www.youtube.com/results";
                params = [
                  {
                    name = "search_query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.fetchurl {
              url = "www.youtube.com/s/desktop/8498231a/img/favicon_144x144.png";
              sha256 = "sha256-lQ5gbLyoWCH7cgoYcy+WlFDjHGbxwB8Xz0G7AZnr9vI=";
            }}";
            definedAliases = [ "@y" ];
          };
        };
      };
    };
  };
}
