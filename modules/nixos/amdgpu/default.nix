{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.nixos.hardware.amdgpu;
in
{
  options = {
    nixos.hardware.amdgpu.enable = lib.mkEnableOption "amdgpu driver support and tweaks";

  };
  config = lib.mkIf cfg.enable {

    hardware.amdgpu.initrd.enable = true;
    services.xserver.videoDrivers = [ "amdgpu" ];

    # Overclocking support
    hardware.amdgpu.overdrive.enable = true;
    # Sets the amdgpu.ppfeaturemask kernel option (includes the overdrive bit).
    # Keep the conservative 0xfffd7fff: 0xffffffff additionally enables
    # PP_GFXOFF_MASK (0x8000) and PP_AVFS_MASK (0x20000), which make this RDNA3
    # card wake immediately from S3 (suspend enters and instantly exits).
    # See [[Gigabyte AORUS b550 Elite v2 fix broken suspend on Linux]].
    hardware.amdgpu.overdrive.ppfeaturemask = "0xfffd7fff";

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
