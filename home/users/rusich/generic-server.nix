{
  # Base only: no user.bundle.* — servers must not pull in GUI or
  # out-of-store (mkOutOfStoreSymlink) features. Deployed wholesale with the
  # system via nixos.home-manager.integrated.
  imports = [ ./home.nix ];
}
