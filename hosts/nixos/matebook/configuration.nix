{
  pkgs,
  nixosModules,
  ...
}:

{
  # Move this to common config?
  system.stateVersion = "25.05";

  imports = [
    ./hardware-configuration.nix
    "${nixosModules}/desktopCommon"
    "${nixosModules}/gamedev.nix"
  ];

  hardware.cpu.intel.updateMicrocode = true;

  # Host-specific configuration
  console = {
    font = "ter-v32b";
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = false; # see the note above
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.prime = {
    intelBusId = "PCI:0@0:2:0";
    nvidiaBusId = "PCI:1@0:0:0";
    # amdgpuBusId = "PCI:5@0:0:0"; # If you have an AMD iGPU
  };

  environment.systemPackages = with pkgs; [
    brightnessctl
    powertop
  ];

  # Host-specific packages
  powerManagement.enable = true;
  powerManagement.powertop.enable = true;

  services.displayManager.sddm.theme = "chili";
  # services.displayManager.sddm.theme = "sugar-dark";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
}
