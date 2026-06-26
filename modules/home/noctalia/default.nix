{
  inputs,
  pkgs,
  config,
  ...
}:
{

  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia = {
    enable = true;
  };

  home.file = {
    ".config/noctalia/config.toml".source =
      config.lib.file.mkOutOfStoreSymlink config.homeModulesPath + "/noctalia/config.toml";
  };

  home.packages = with pkgs; [
    adw-gtk3
    nwg-look
    kdePackages.qt6ct
    libsForQt5.qt5ct
    pywalfox-native
  ];

  # set environment variables
  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt6ct";
    TESSSST = "sdfsfaf";
  };

  home.activation.setAdwGtk3Theme = inputs.nixpkgs.lib.mkAfter ''
    ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3' || true
  '';

  home.activation.touchFiles = inputs.nixpkgs.lib.mkAfter ''
    touch ${config.home.homeDirectory}/.config/niri/noctalia.kdl
    touch ${config.home.homeDirectory}/.config/rofi/noctalia.rasi
  '';
}
