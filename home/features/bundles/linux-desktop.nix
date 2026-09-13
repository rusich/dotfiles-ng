# Meta-feature: Linux desktop bundle.
#
# Pair with user.bundle.graphical. Servers must NOT enable it.
{
  config,
  lib,
  ...
}:
let
  cfg = config.user.bundle.linux-desktop;
in
{
  options.user.bundle.linux-desktop.enable =
    lib.mkEnableOption "Linux desktop bundle (niri, rofi, kitty, ...)";

  config = lib.mkIf cfg.enable {
    user.desktop = {
      niri.enable = true;
      noctalia.enable = true;
      rofi.enable = true;
      kitty.enable = true;
      udiskie.enable = true;
      mimeapps.enable = true;
      packages.enable = true;
    };
  };
}
