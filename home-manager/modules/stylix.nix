{ config, pkgs, ... }:

{
  # Stylix
  stylix.targets.kde.enable = true;
  stylix.targets.firefox = {
    enable = true;
    profileNames = [ "${config.home.username}" ];
    colorTheme.enable = true;
  };

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