{ config, ... }:
{
  # Включаем управление XDG User Directories (но с кастомными путями)
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = "${config.home.homeDirectory}/Desktop";
    download = "${config.home.homeDirectory}/Downloads";
    documents = "${config.home.homeDirectory}/Nextcloud/Documents";
    templates = "${config.home.homeDirectory}/Nextcloud/Templates";
    music = "${config.home.homeDirectory}/Nextcloud/Music";
    videos = "${config.home.homeDirectory}/Nextcloud/Videos";
    pictures = "${config.home.homeDirectory}/Nextcloud/Pictures";
    publicShare = "${config.home.homeDirectory}/Public";
    projects = "${config.home.homeDirectory}/Projects";
    setSessionVariables = true;
  };
}
