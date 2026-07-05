{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.apple-macbook-air-7
  ];

  # Enable custom modules
  my.nixosModules.desktop-common.enable = true;
  my.nixosModules.gnome.enable = true;

  # swap alt and cmd
  boot.kernelParams = [
    "hid_apple.swap_opt_cmd=1"
  ];

  powerManagement = {
    enable = true;
  };

  hardware = {
    # Enable harware graphics support
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  # Enable daemon for temperature monitoring
  services.thermald.enable = true;

  # Users configuration
  users = {
    users = {
      rusich = {
        isNormalUser = true;
        description = "Ruslan Sergin";
        extraGroups = [
          "wheel" # Enables sudo for user
          "networkmanager" # Enable Wi-Fi connections for user
        ];
      };
      bunny = {
        isNormalUser = true;
        description = "Sakhaya Sergina";
        extraGroups = [
          "networkmanager" # Enable Wi-Fi connections for user
        ];
      };
    };
  };

  # MacBook Air specific
  # Wi-Fi card and Bluetooth on iMac require redistributable firmware
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  boot.kernelModules = [
    "kvm-intel"
    "wl"
  ];
  # boot.extraModulePackages = [config.boot.kernelPackages.broadcom_sta];

  boot.extraModulePackages = with config.boot.kernelPackages; [
    broadcom_sta
    # apple_bce
  ];
  nixpkgs.config.permittedInsecurePackages = [
    "broadcom-sta-6.30.223.271-59-6.18.37"
  ];
  boot.blacklistedKernelModules = [ "b43" ];

  services.openssh.settings.PermitRootLogin = "yes";

  zramSwap = {
    enable = true;
    # Allow utilizing 60% of RAM for compressed swap
    memoryPercent = 60;
  };

  # Configure networking
  networking.enableB43Firmware = false;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "25.11";
}
