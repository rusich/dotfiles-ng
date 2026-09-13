{
  imports = [ ./home.nix ];

  user.bundle.graphical.enable = true;

  # Only the cross-platform parts of the desktop group run on macOS.
  user.desktop.kitty.enable = true;
}
