{ config, pkgs, userSettings, inputs, system, ... }: {
  imports = [
    ./shell.nix
    ./git.nix
    ./pkgs.nix
    ./file.nix
    ./vars.nix
    ./path.nix
    ./dircolors.nix
    # inputs.nix-colors.homeManagerModules.default
    # ./theming-example/alacritty.nix
  ];

  programs.alacritty.enable = true;

  # Включаем управление XDG User Directories (но с кастомными путями)
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = "$HOME/Desktop";
    download = "$HOME/Downloads";
    documents = "$HOME/Nextcloud/Documents";
    templates = "$HOME/Nextcloud/Templates";
    music = "$HOME/Nextcloud/Music";
    videos = "$HOME/Nextcloud/Videos";
    pictures = "$HOME/Nextcloud/Pictures";
    publicShare = "$HOME/Public";
    # extraConfig = { XDG_DESKTOP_DIR = "$HOME/Desktop"; };
  };

  # Dolphin force recreate bookmarks from user-dirs
  home.activation.removeConfigFile =
    config.lib.dag.entryAfter [ "writeBoundary" ] ''
      rm -f "$HOME/.local/share/user-places.xbel"
    '';

  # SwayOSD 
  services.swayosd.enable = true;

  # Hyprland
  wayland.windowManager.hyprland.systemd.enableXdgAutostart = true;
  # set color scheme from base16 (https://github.com/tinted-theming/schemes) 
  # colorScheme = inputs.nix-colors.colorSchemes.oxocarbon-light;

  xdg.portal = {
    enable = true;
    config = { common = { default = [ "gtk" ]; }; };
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
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
  home.stateVersion = "25.05";

  # Stylix
  stylix.targets.kde.enable = true;
  stylix.targets.firefox = {
    enable = true;
    profileNames = [ "${userSettings.username}" ];
    colorTheme.enable = true;
    # firefoxGnomeTheme.enable = true;
  };

  stylix.cursor = {
    package = pkgs.bibata-cursors;
    size = 24;
    name = "Bibata-Modern-Ice";
  };

  stylix.fonts = {

    monospace = {
      # package =  pkgs.nerd-fonts._0xproto.override { fonts = [ "JetBrainsMono" ]; };
      package = pkgs.nerd-fonts.iosevka-term;
      name = "Iosevka Nerd Font Mono";
    };
    sansSerif = {
      package = pkgs.dejavu_fonts;
      name = "DejaVu Sans";
    };
    serif = {
      package = pkgs.dejavu_fonts;
      name = "DejaVu Serif";
    };
  };

  stylix.fonts.sizes = {
    applications = 12;
    terminal = 15;
    desktop = 10;
    popups = 10;
  };

  stylix.opacity = {
    applications = 1.0;
    terminal = 1.0;
    desktop = 1.0;
    popups = 0.7;
  };

  services.remmina.enable = true;

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
        "identity.fxaccounts.enabled" = false;

      };

      extensions = {
        force = true;
        packages = with inputs.firefox-addons.packages.${system}; [
          keepassxc-browser
          simple-translate
        ];
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
            definedAliases = [ "@ny" ];
          };

          "Nixhub" = {
            urls = [{ template = "https://www.nixhub.io/packages/"; }];
            icon =
              "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@nh" ];
          };

          "HM options" = {
            urls = [{
              template = "https://home-manager-options.extranix.com/";
              params = [{
                name = "query";
                value = "{searchTerms}";
              }];
            }];
            icon =
              "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@nm" ];
          };

          "Nix func" = {
            urls = [{
              template = "https://noogle.dev/q";
              params = [{
                name = "term";
                value = "{searchTerms}";
              }];
            }];
            icon =
              "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@nf" ];
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
