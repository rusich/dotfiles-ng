{ config, pkgs, userSettings, inputs, system, ... }: {
  imports = [
    ./shell.nix
    ./git.nix
    ./pkgs.nix
    ./file.nix
    ./vars.nix
    ./path.nix
    ./dircolors.nix
  ];

  xdg.portal = {
    enable = true;
    config = { common = { default = [ "gtk" ]; }; };
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  gtk = {
    enable = true;
    theme.name = "WhiteSur-Dark";
    cursorTheme.name = "Bibata-Modern-Classic";
    iconTheme.name = "WhiteSur-Dark";
  };

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = userSettings.username;
  home.homeDirectory = "/home/" + userSettings.username;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  programs.firefox = {
    enable = true;

    profiles.${userSettings.username} = {
      settings = {
        "dom.security.https_only_mode" = true;
        "browser.translations.enable" = false;
        "signon.rememberSignons" = false;
        "browser.places.importBookmarksHTML" = true;
        "browser.bookmarks.autoExportHTML" = true;
        "browser.bookmarks.file" =
          "/home/${userSettings.username}/Nextcloud/Configs/bookmarks.html";
        # Look'n'feel
        "sidebar.verticalTabs" = true;
        # "sidebar.visibility" = "expand-on-hover";
        "browser.toolbars.bookmarks.visibility" = "never";

      };

      extensions = {
        packages = with inputs.firefox-addons.packages.${system};
          [ keepassxc-browser ];
      };

      search = {
        force = true;
        default = "ddg";
        order = [ "ddg" "google" ];
        engines = {
          "Amazon.ca".metaData.alias = "@a";
          "bing".metaData.hidden = true;
          "ebay".metaData.hidden = true;
          "google".metaData.alias = "@g";
          "wikipedia".metaData.alias = "@w";

          "GitHub" = {
            urls = [{
              template = "https://github.com/search";
              params = [{
                name = "q";
                value = "{searchTerms}";
              }];
            }];
            icon = "${pkgs.fetchurl {
              url = "https://github.githubassets.com/favicons/favicon.svg";
              sha256 = "sha256-apV3zU9/prdb3hAlr4W5ROndE4g3O1XMum6fgKwurmA=";
            }}";
            definedAliases = [ "@gh" ];
          };

          "Nix Packages" = {
            urls = [{
              template = "https://search.nixos.org/packages";
              params = [
                {
                  name = "channel";
                  value = "25.05";
                }
                {
                  name = "query";
                  value = "{searchTerms}";
                }
              ];
            }];
            icon =
              "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };

          "Nix Options" = {
            urls = [{
              template = "https://search.nixos.org/options";
              params = [
                {
                  name = "channel";
                  value = "25.05";
                }
                {
                  name = "query";
                  value = "{searchTerms}";
                }
              ];
            }];
            icon =
              "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@no" ];
          };

          "NixOS Wiki" = {
            urls = [{
              template = "https://nixos.wiki/index.php";
              params = [{
                name = "search";
                value = "{searchTerms}";
              }];
            }];
            icon =
              "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@nw" ];
          };

          "Nixpkgs Issues" = {
            urls = [{
              template = "https://github.com/NixOS/nixpkgs/issues";
              params = [{
                name = "q";
                value = "{searchTerms}";
              }];
            }];
            icon =
              "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@ni" ];
          };

          "MyNixOS" = {
            urls = [{
              template = "https://mynixos.com/search";
              params = [{
                name = "q";
                value = "{searchTerms}";
              }];
            }];
            icon =
              "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@mn" ];
          };

          # A good way to find genuine discussion
          "reddit" = {
            urls = [{
              template = "https://www.reddit.com/search";
              params = [{
                name = "q";
                value = "{searchTerms}";
              }];
            }];
            icon = "${pkgs.fetchurl {
              url =
                "https://www.redditstatic.com/accountmanager/favicon/favicon-512x512.png";
              sha256 = "sha256-4zWTcHuL1SEKk8KyVFsOKYPbM4rc7WNa9KrGhK4dJyg=";
            }}";
            definedAliases = [ "@r" ];
          };

          "Youtube" = {
            urls = [{
              template = "https://www.youtube.com/results";
              params = [{
                name = "search_query";
                value = "{searchTerms}";
              }];
            }];
            icon = "${pkgs.fetchurl {
              url =
                "www.youtube.com/s/desktop/8498231a/img/favicon_144x144.png";
              sha256 = "sha256-lQ5gbLyoWCH7cgoYcy+WlFDjHGbxwB8Xz0G7AZnr9vI=";
            }}";
            definedAliases = [ "@y" ];
          };
        };
      };
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
