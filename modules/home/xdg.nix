{
  pkgs,
  lib,
  ...
}: {
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
    setSessionVariables = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = [ "gtk" ];
  };
}
