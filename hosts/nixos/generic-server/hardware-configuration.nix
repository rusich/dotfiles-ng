# Minimal QEMU guest hardware stub. Regenerated on install by
# `just install generic-server <target>` (nixos-anywhere --generate-hardware-config).
{
  config,
  lib,
  pkgs,
  ...
}:
{
  boot.initrd.availableKernelModules = [
    "ahci"
    "xhci_pci"
    "virtio_pci"
    "virtio_scsi"
    "sr_mod"
    "virtio_blk"
  ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
