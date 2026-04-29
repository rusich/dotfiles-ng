{
  ...
}:
{
  # Nix configuration specific for nixos
  # Also imoprted by home-manager module ../home/nix.nix
  nix = {
    settings.auto-optimise-store = true; # every build
    # optimise = {
    #   automatic = true;
    #   dates = [ "daily" ];
    # };

    # cleanup system automatically
    gc = {
      dates = "weekly";
    };
  };

}
