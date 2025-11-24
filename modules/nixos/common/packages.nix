{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    file
    usbutils
    pciutils
    dig
  ];
}
