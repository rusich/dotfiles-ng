# Preset for macOS machines.
{
  imports = [ ./shared.nix ];

  # Only the cross-platform parts of the desktop group run on macOS.
  user.desktop.kitty.enable = true;

  # macOS-only features go here.
}
