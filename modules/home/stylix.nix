{ config, pkgs, ... }:

{
  stylix.enable = true;
  stylix.targets = {
    nixvim.enable = false;
    gtk.enable = true;
    qt = {
      enable = true;
      platform = "qtct";
    };
    kde.enable = false;
    gnome.enable = true;
    firefox = {
      enable = true;
      profileNames = [ "${config.home.username}" ];
      colorTheme.enable = true;
    };
  };

  stylix.polarity = "dark";
  # theme gallery: https://tinted-theming.github.io/tinted-gallery/
  # stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/stella.yaml";
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/oxocarbon-dark.yaml";
  # "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
  # "${pkgs.base16-schemes}/share/themes/windows-10-light.yaml";
  # "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

  stylix.icons = {
    enable = true;
    # # Papirus with customizable folder colors
    # package = pkgs.catppuccin-papirus-folders.override {
    #   flavor = "mocha"; # [   "latte" "frappe" "macchiato" "mocha" ]
    #   accent = "mauve"; # "blue" "flamingo" "green" "lavender" "maroon" "mauve"
    #   #"peach" "pink" "red" "rosewater" "sapphire" "sky" "teal" "yellow"
    # };
    # light = "Papirus-White";
    # dark = "Papirus-Dark";

    # Whitesur
    package = pkgs.whitesur-icon-theme.override {
      # boldPanelIcons ? false,
      # blackPanelIcons ? false,
      # alternativeIcons ? false,
      themeVariants = [ "yellow" ]; # [ "default" "purple" "pink" "red" "orange" "yellow" "green" "grey" "nord" "all" ]
    };
    light = "WhiteSur-yellow-light";
    dark = "WhiteSur-yellow-dark";

    # # Flat Remix
    # package = pkgs.flat-remix-icon-theme;
    # light = "Flat-Remix-Brown-Light-darkPanel";
    # dark = "Flat-Remix-Brown-Dark";

    # # Kora
    # package = pkgs.kora-icon-theme;
    # light = "Kora-Light";
    # dark = "Kora-Light";
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

    # monospace = {
    #   package = pkgs.nerd-fonts.fira-code;
    #   name = "Fira Code NerdFont";
    # };

    serif = {
      package = pkgs.dejavu_fonts;
      name = "DejaVu Serif";
    };

    sansSerif = {
      package = pkgs.dejavu_fonts;
      name = "DejaVu Sans";
    };

    emoji = {
      package = pkgs.noto-fonts-color-emoji;
      name = "Noto Color Emoji";
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
