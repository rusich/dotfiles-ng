{
  config,
  pkgs,
  userSettings,
  ...
}:

{
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
  };

  # Dolphin force recreate bookmarks from user-dirs
  home.activation.removeConfigFile = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    rm -f "$HOME/.local/share/user-places.xbel"
  '';

  xdg.portal = {
    enable = false;
    config = {
      common = {
        default = [ "gtk" ];
      };
      hyprland = {
        default = [
          "hyprland"
          "gtk"
        ];
        "org.freedesktop.impl.portal.ScreenCast" = [
          "gnome"
        ];
      };
    };
    extraPortals = [
      # pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
  };
}
