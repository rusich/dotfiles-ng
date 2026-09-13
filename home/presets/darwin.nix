# Preset for macOS machines.
{
  imports = [ ./shared.nix ];

  # Only the cross-platform parts of the desktop group run on macOS.
  features.desktop.kitty.enable = true;

  # macOS-only features go here.
}
