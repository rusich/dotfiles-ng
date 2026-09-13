{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.gui.packages;
in
{
  options.features.gui.packages.enable = lib.mkEnableOption "common cross-platform GUI applications";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      whitesur-gtk-theme
      gnome-calculator
      discord
      showtime
      mpv
      telegram-desktop
    ];

    services.remmina.enable = true;
  };
}
