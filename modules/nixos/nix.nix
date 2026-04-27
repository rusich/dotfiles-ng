{
  ...
}:
{
  # Nix configuration specific for nixos
  # Also imoprted by home-manager module ../home/nix.nix
  nix = {
    settings = {
      auto-optimise-store = true;
    };

    # cleanup system automatically
    gc = {
      dates = "weekly";
    };
  };
}
