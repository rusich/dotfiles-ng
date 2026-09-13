{
  imports = [ ./home.nix ];

  user.bundle = {
    graphical.enable = true;
    linux-desktop.enable = true;
  };

  # Web-UI hub (traefik → phone) runs only on darkstar.
  user.opencode.server.enable = true;
}
