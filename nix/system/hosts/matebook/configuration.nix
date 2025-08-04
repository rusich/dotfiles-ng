{ pkgs, hostname, ... }:

{
  imports = [
    ./hardware-configuration.nix
    # ./local-packages.ni
    ../../configuration.nix
    ]

  networking.hostName = hostname;
}
