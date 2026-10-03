{
  imports = [ ./home.nix ];

  user.bundle = {
    graphical.enable = true;
    linux-desktop.enable = true;
  };

  # sops-nix secrets (personal age key) — desktops only.
  user.secrets.enable = true;
}
