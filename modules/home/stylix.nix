{ config, pkgs, ... }:

{
  stylix.enable = true;
  stylix.targets = {
  nixvim.enable = false;
    gtk.enable = true;
    qt.enable = true;
    kde.enable = false;
    firefox = {
      enable = true;
      profileNames = [ "${config.home.username}" ];
      colorTheme.enable = true;
    };
  };

  stylix.polarity = "dark";
  stylix.base16Scheme =
    # "${pkgs.base16-schemes}/share/themes/oxocarbon-dark.yaml";
    # "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    # "${pkgs.base16-schemes}/share/themes/windows-10-light.yaml";
    "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

  stylix.cursor = {
    package = pkgs.bibata-cursors;
    size = 24;
    name = "Bibata-Modern-Ice";
  };

  stylix.fonts = {
    monospace = {
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
}
