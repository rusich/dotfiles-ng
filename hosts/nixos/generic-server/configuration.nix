{
  modulesPath,
  lib,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./hardware-configuration.nix
    ./disko.nix
  ];

  # disko creates a BIOS-boot (EF02) + ESP layout; grub installs into the ESP
  # without touching NVRAM, so the image boots under both BIOS and UEFI.
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking.useDHCP = lib.mkDefault true;

  # Serial console for `virsh console` / headless access; systemd's getty
  # generator spawns serial-getty@ttyS0 from the kernel cmdline.
  boot.kernelParams = [
    "console=tty0"
    "console=ttyS0,115200n8"
  ];

  # Headless-server settings (daily gc, resolved, key-only ssh, extra tools).
  nixos.profiles.server.enable = true;

  # Deploy home-manager together with the system (see home/users/rusich/generic-server.nix).
  nixos.home-manager.integrated.enable = true;

  system.stateVersion = "26.05";
}
