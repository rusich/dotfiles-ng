# XDG user directories (Desktop/Downloads/Nextcloud/...). Linux desktop
# feature: enabled by the linux-desktop bundle or explicitly per user.
# Not used on macOS (XDG user dirs are not a native macOS concept).
{
  config,
  lib,
  ...
}:
let
  cfg = config.user.gui.userDirs;
in
{
  options.user.gui.userDirs.enable = lib.mkEnableOption "XDG user directories";

  config = lib.mkIf cfg.enable {
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
  };
}
