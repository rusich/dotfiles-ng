{
  inputs,
  pkgs,
  lib,
  primaryUser,
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
    # Adds the nixpkgs source to the closure (~485 MiB) so `<nixpkgs>` lookups
    # and nixd work. Shared by all hosts, so servers carry it too.
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    # settings.auto-optimise-store = true; # every build
    settings = {
      trusted-users = [
        "${primaryUser.username}"
        "@wheel"
      ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      http2 = true; # NOTE: turn off with DPI problems
      accept-flake-config = true;
    };

  };
}
