{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.my.nixosModules.amdgpu;
in
{
  options = {
    my.nixosModules.amdgpu.enable = lib.mkEnableOption "amdgpu driver support and tweaks";

  };
  config = lib.mkIf cfg.enable {

    hardware.amdgpu.initrd.enable = true;
    services.xserver.videoDrivers = [ "amdgpu" ];

    # Overclocking support
    hardware.amdgpu.overdrive.enable = true;
    # ets the amdgpu.ppfeaturemask kernel option. It can be used to enable the overdrive bit.
    # Default is 0xfffd7fff as it is less likely to cause flicker issues. Setting it to 0xffffffff enables all features,
    # but also can be unstable. See the kernel documentation for more information.
    hardware.amdgpu.overdrive.ppfeaturemask = "0xffffffff";

    # ROCm

    # Enable ROCm compute support
    hardware.amdgpu.opencl.enable = true;
    # nixpkgs.config.rocmSupport = true;

    # Install verification utilities
    environment.systemPackages = with pkgs; [
      # rocmPackages.rocminfo
      clinfo
      nvtopPackages.amd
    ];
  };
}
