{
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.huawei-machc-wa
  ];

  # Enable custom modules
  nixos.profiles.desktop.enable = true;

  # TODO: it is temporary fix for niri destkop session
  # is broken in NixOS 26.05 (not shown in GDM greeter)
  nixos.profiles.gnome.enable = true;
  nixos.profiles.gamedev.enable = true;
  nixos.services.podman.enable = true;

  # Old Hardware-Specifice settings replaced by NixOS-Hardware module
  # hardware.cpu.intel.updateMicrocode = true;

  # 8GB RAM laptop: compressed swap avoids hitting the slow disk swap
  # (zram gets higher swap priority than the LUKS partition automatically)
  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  # Thin chassis + "performance" power profile -> thermal throttling
  # causes the visible stutter; thermald keeps the CPU within safe limits
  services.thermald.enable = true;

  # Host-specific configuration
  console = {
    font = "ter-v32b";
  };
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
  #
  # powerManagement.enable = true;
  # powerManagement.powertop.enable = true;

  # Move this to common config?
  system.stateVersion = "25.05";
}
