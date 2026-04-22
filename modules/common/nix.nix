{
  lib,
  inputs,
  pkgs,
  ...
}:
{
  # Nix store optimisation

  nix = {
    package = pkgs.nix;
    # Userful for nixd
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    settings = {
      trusted-users = [
        "root"
        "rusich"
        "@wheel"
      ];
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      http2 = true; # NOTE: turn off with DPI problems
    };

    # cleanup system automatically
    gc = {
      automatic = lib.mkDefault true;
      dates = "weekly";
      options = lib.mkDefault "--delete-older-than 7d";
    };
  };
}
