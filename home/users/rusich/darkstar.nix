{
  imports = [ ./home.nix ];

  user.bundle = {
    graphical.enable = true;
    linux-desktop.enable = true;
  };

  user.gaming.lutris.enable = true;

  # sops-nix secrets (personal age key) — desktops only.
  user.secrets.enable = true;

  # Web-UI hub (traefik → phone) runs only on darkstar.
  user.opencode.server.enable = true;
}
