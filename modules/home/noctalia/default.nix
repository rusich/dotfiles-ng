{
  pkgs,
  config,
  ...
}:
{
  home.packages = with pkgs; [
    unstable.noctalia
    adw-gtk3
    nwg-look
    kdePackages.qt6ct
    libsForQt5.qt5ct
    pywalfox-native
  ];

  home.file = {
    ".config/noctalia/config.toml".source =
      config.lib.file.mkOutOfStoreSymlink config.homeModulesPath + "/noctalia/config.toml";
  };

  # set environment variables
  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt6ct";
  };

  home.activation.touchFiles = pkgs.lib.mkAfter ''
    touch ${config.home.homeDirectory}/.config/niri/noctalia.kdl
    touch ${config.home.homeDirectory}/.config/rofi/noctalia.rasi
  '';
}
