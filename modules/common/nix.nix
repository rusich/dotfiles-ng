{
  inputs,
  pkgs,
  lib,
  userConfig,
  ...
}:
{
  # Nix configuration common for all systems
  nix = {
    gc = {
      automatic = lib.mkDefault true;
      options = lib.mkDefault "--delete-older-than 7d";
    };

    package = pkgs.nix;
    # Userful for nixd
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    # settings.auto-optimise-store = true; # every build
    settings = {
      trusted-users = [
        "${userConfig.username}"
        "@wheel"
      ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      http2 = true; # NOTE: turn off with DPI problems
    };

  };
}
