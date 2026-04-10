{
  pkgs,
  nixosModules,
  inputs,
  ...
}:

{
  # Move this to common config?
  system.stateVersion = "25.05";

  imports = [
    ./hardware-configuration.nix
    "${nixosModules}/desktopCommon"
    "${nixosModules}/gamedev.nix"
    inputs.nixos-hardware.nixosModules.huawei-machc-wa
  ];

  # Old Hardware-Specifice settings replaced by NixOS-Hardware module
  # hardware.cpu.intel.updateMicrocode = true;
  #
  # # Host-specific configuration
  # console = {
  #   font = "ter-v32b";
  # };
  #
  # hardware.graphics = {
  #   enable = true;
  #   enable32Bit = true;
  # };
  #
  # services.xserver.videoDrivers = [ "nvidia" ];
  # hardware.nvidia.open = false; # see the note above
  # hardware.nvidia.modesetting.enable = true;
  # hardware.nvidia.prime = {
  #   intelBusId = "PCI:0@0:2:0";
  #   nvidiaBusId = "PCI:1@0:0:0";
  #   # amdgpuBusId = "PCI:5@0:0:0"; # If you have an AMD iGPU
  # };
  #
  # Host-specific packages
  environment.systemPackages = with pkgs; [
    # brightnessctl
    # powertop
    wireguard-tools
    wireguard-ui
  ];
  #
  # powerManagement.enable = true;
  # powerManagement.powertop.enable = true;

  services.displayManager.sddm.theme = "chili";
  # services.displayManager.sddm.theme = "sugar-dark";
}
