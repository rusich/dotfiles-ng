{
  pkgs,
  config,
  lib,
  ...
}:
let
  # custom amdgpu kernel module with some patches
  amdgpu-kernel-module = pkgs.callPackage ./amdgpu-kernel-module.nix {
    # Make sure the module targets the same kernel as your system is using.
    kernel = config.boot.kernelPackages.kernel;
  };
  amd-gpu-ignore-ctx-privileges-patch = pkgs.fetchpatch {
    name = "cap_sys_nice_begone.patch";
    url = "https://github.com/Frogging-Family/community-patches/raw/master/linux61-tkg/cap_sys_nice_begone.mypatch";
    hash = "sha256-Y3a0+x2xvHsfLax/uwycdJf3xLxvVfkfDVqjkxNaYEo=";
  };
  cfg = config.my.nixosModules.amdgpu;
in
{
  options = {
    my.nixosModules.amdgpu.enable = lib.mkEnableOption "amdgpu driver support and tweaks";

  };
  config = lib.mkIf cfg.enable {

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    hardware.amdgpu.initrd.enable = true;
    hardware.cpu.amd.updateMicrocode = true;
    services.xserver.videoDrivers = [ "amdgpu" ];
    # for corectrl full features
    boot.kernelParams = [ "amdgpu.ppfeaturemask=0xffffffff" ];

    boot.extraModulePackages = [
      (amdgpu-kernel-module.overrideAttrs (_: {
        patches = [
          # amdgpu-stability-patch
          amd-gpu-ignore-ctx-privileges-patch
          # ./patches/amdgpu-stability-patch.diff
        ];
      }))
    ];
  };
}
