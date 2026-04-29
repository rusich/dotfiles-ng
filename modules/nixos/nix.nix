# common nixos and home-manager settings for nix
# This module automatically loaded in all nixos configurations
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
