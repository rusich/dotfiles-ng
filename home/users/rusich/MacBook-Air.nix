{
  # Base only: no user.bundle.* — MacBook-Air has no local dotfiles checkout,
  # so it must not pull in GUI or out-of-store (mkOutOfStoreSymlink) features.
  # Deployed wholesale with the system via nixos.home-manager.integrated,
  # exactly like the server profile.
  imports = [ ./home.nix ];
}
