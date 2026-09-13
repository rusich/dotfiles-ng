# Preset for Linux desktop machines.
{
  imports = [ ./shared.nix ];

  user.desktop = {
    niri.enable = true;
    noctalia.enable = true;
    rofi.enable = true;
    kitty.enable = true;
    udiskie.enable = true;
    mimeapps.enable = true;
    packages.enable = true;
  };
}
