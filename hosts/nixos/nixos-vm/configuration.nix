{
  pkgs,
  unstable,
  nixosModules,
  ...
}:

{
  # Move this to common config?
  system.stateVersion = "25.05";

  imports = [
    ./hardware-configuration.nix
    # ../split_me.nix
    "${nixosModules}/split_me.nix"
  ];

  # Host-specific configuration

  # Host-specific packages
  environment.systemPackages = with pkgs; [
    # some useful stuff...
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
}
