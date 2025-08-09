{ config, pkgs, userSettings, ... }: {
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
    theme.name = "Adwaita";
    cursorTheme.name = "Bibata-Modern-Classic";
    iconTheme.name = "GruvboxPlus";
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
      };
      bookmarks = {
        force = true;
        settings = [{
          name = "wikipedia";
          tags = [ "wiki" ];
          keyword = "wiki";
          url = "https://en.wikipedia.org/wiki/Main_Page";

        }];
      };
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
