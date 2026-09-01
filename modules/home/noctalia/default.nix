{
  pkgs,
  config,
  lib,
  ...
}:
lib.mkIf pkgs.stdenv.isLinux {
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

  # Fallback: предварительно создаём пустые файлы-заглушки для всех выходных файлов
  # активированных шаблонов тем (см. [theme.templates] в config.toml) и их родительские
  # каталоги. Noctalia перезаписывает их при каждой смене темы и падает, если файл
  # не существует. Содержимое динамическое (генерируется noctalia), поэтому файлы не
  # коммитятся в репозиторий и исключены через локальные .gitignore (rofi/niri/kitty/nvim).
  home.activation.touchFiles = pkgs.lib.mkAfter ''
    mkdir -p \
      ${config.home.homeDirectory}/.config/btop/themes \
      ${config.home.homeDirectory}/.config/gtk-3.0 \
      ${config.home.homeDirectory}/.config/gtk-4.0 \
      ${config.home.homeDirectory}/.local/share/color-schemes \
      ${config.home.homeDirectory}/.config/kitty/themes \
      ${config.home.homeDirectory}/.config/niri \
      ${config.home.homeDirectory}/.config/qt5ct/colors \
      ${config.home.homeDirectory}/.config/qt6ct/colors \
      ${config.home.homeDirectory}/.config/opencode/themes \
      ${config.home.homeDirectory}/.cache/wal \
      ${config.home.homeDirectory}/.config/telegram-desktop/themes \
      ${config.home.homeDirectory}/.steam/steam/steamui/skins/Material-Theme/css/main/colors \
      ${config.home.homeDirectory}/.config/rofi \
      ${config.home.homeDirectory}/.config/yazi/flavors/noctalia.yazi \
      ${config.home.homeDirectory}/.config/nvim/lua

    touch \
      ${config.home.homeDirectory}/.config/btop/themes/noctalia.theme \
      ${config.home.homeDirectory}/.config/gtk-3.0/noctalia.css \
      ${config.home.homeDirectory}/.config/gtk-4.0/noctalia.css \
      ${config.home.homeDirectory}/.local/share/color-schemes/noctalia.colors \
      ${config.home.homeDirectory}/.config/kitty/themes/noctalia.conf \
      ${config.home.homeDirectory}/.config/niri/noctalia.kdl \
      ${config.home.homeDirectory}/.config/qt5ct/colors/noctalia.conf \
      ${config.home.homeDirectory}/.config/qt6ct/colors/noctalia.conf \
      ${config.home.homeDirectory}/.config/opencode/themes/matugen.json \
      ${config.home.homeDirectory}/.cache/wal/colors.json \
      ${config.home.homeDirectory}/.config/telegram-desktop/themes/noctalia.tdesktop-theme \
      ${config.home.homeDirectory}/.steam/steam/steamui/skins/Material-Theme/css/main/colors/matugen.css \
      ${config.home.homeDirectory}/.config/rofi/noctalia.rasi \
      ${config.home.homeDirectory}/.config/yazi/flavors/noctalia.yazi/flavor.toml \
      ${config.home.homeDirectory}/.config/yazi/flavors/noctalia.yazi/tmtheme.xml \
      ${config.home.homeDirectory}/.config/nvim/lua/matugen.lua
  '';
}
