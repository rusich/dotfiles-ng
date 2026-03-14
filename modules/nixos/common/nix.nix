# Common `nix` settings
{ lib, inputs, ... }:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

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
    enable = true;
    dates = "weekly";
  };

  # Fix hardware clock on dualboot
  time.hardwareClockInLocalTime = true;

  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
}
