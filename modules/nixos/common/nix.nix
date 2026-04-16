# Common `nix` settings
{
  lib,
  inputs,
  pkgs,
  ...
}:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.settings = {
    http2 = true; # NOTE: turn off with DPI problems
  };

  # cleanup system automatically
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = "daily";
    options = lib.mkDefault "--delete-older-than 7d";
  };

  # Nix store optimisation
  nix.settings.auto-optimise-store = true;
  nix.optimise = {
    automatic = true;
    dates = [ "daily" ];
  };

  # Automatic upgrading
  system.autoUpgrade = {
    enable = false;
    allowReboot = false;
    # flake = "/path/to/flake";
    dates = "weekly";

  };

  # Fix hardware clock on dualboot
  time.hardwareClockInLocalTime = true;

  # Userful for nixd
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  environment.systemPackages = with pkgs; [
    nix-inspect
  ];
}
