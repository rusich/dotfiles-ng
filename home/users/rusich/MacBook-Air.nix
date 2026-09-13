{
  imports = [ ./home.nix ];

  user.bundle = {
    graphical.enable = true;
    linux-desktop.enable = true;
  };
}
