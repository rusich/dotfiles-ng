{
  config,
  lib,
  ...
}:
{
  # Nix configuration specific for home-manager
  imports = [ ../../modules/nixos/nix.nix ];

  # Let nh know the flake: uses the same dotfilesPath as aliases and
  # mkOutOfStoreSymlink paths. Works on Linux and macOS.
  programs.nh = {
    enable = true;
    flake = config.dotfilesPath;
  };
}
