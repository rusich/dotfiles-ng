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

  powerManagement = {
    enable = true;
  };

  hardware = {
    # Enable hardware graphics support
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
          "wheel"
          "networkmanager"
        ];
      };
      bunny = {
        isNormalUser = true;
        description = "Sakhaya Sergina";
        extraGroups = [
          "networkmanager"
        ];
      };
    };
  };

  # MacBook Air specific

  boot.initrd.availableKernelModules = [
    "ext4" # Добавляем
    "usbcore" # Добавляем
    "scsi_mod" # Добавляем
  ];

  boot.initrd.kernelModules = [
    "usb_storage" # Добавляем
    "ext4" # Добавляем
  ];
  # boot.initrd.postDeviceCommands = lib.mkAfter ''
  #   # Ждём появления swap-раздела
  #   for i in 1 2 3 4 5 6 7 8 9 10; do
  #     if [ -e /dev/sda3 ]; then
  #       break
  #     fi
  #     sleep 1
  #   done
  # '';

  # Параметры ядра
  boot.kernelParams = [
    "hid_apple.swap_opt_cmd=1"
    "mem_sleep_default=deep"
    "i915.enable_psr=0"
    "pcie_aspm=off"
    # Явно указываем устройство
    "resume=/dev/sda3"
    # Добавляем время ожидания для USB
    "resume_wait=10"
    # Добавляем параметры для корректного восстановления
    "acpi_sleep=nonvs"
    # "acpi_osi=!Windows 2013"
  ];

  # Указываем устройство для гибернации
  boot.resumeDevice = "/dev/sda3";

  # Отключаем заморозку сессий через Service-файл systemd-suspend
  systemd.services.systemd-suspend = {
    serviceConfig = {
      Environment = "SYSTEMD_SLEEP_FREEZE_USER_SESSIONS=false";
    };
  };

  # Принудительно пробуждаем SD-ридер после выхода из сна
  systemd.services.fix-sd-reader = {
    description = "Reinitialize SD card reader after resume";
    after = [ "systemd-suspend.service" ];
    wantedBy = [ "suspend.target" ];
    script = ''
      sleep 2
      echo 0 > /sys/bus/usb/devices/2-2/authorized 2>/dev/null || true
      sleep 1
      echo 1 > /sys/bus/usb/devices/2-2/authorized 2>/dev/null || true
      echo "- - -" > /sys/class/scsi_host/host0/scan 2>/dev/null || true
      echo "- - -" > /sys/class/scsi_host/host1/scan 2>/dev/null || true
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = false;
    };
  };

  # Настройка logind для гибернации вместо сна
  # services.logind.extraConfig = ''
  #   HandleLidSwitch=hibernate
  #   HandleLidSwitchExternalPower=hibernate
  #   HandleLidSwitchDocked=ignore
  #   IdleAction=hibernate
  #   IdleActionSec=15min
  # '';

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  boot.kernelModules = [
    "kvm-intel"
    "wl"
  ];

  boot.extraModulePackages = with config.boot.kernelPackages; [
    broadcom_sta
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "broadcom-sta-6.30.223.271-59-6.18.37"
  ];

  boot.blacklistedKernelModules = [ "b43" ];

  services.openssh.settings.PermitRootLogin = "yes";

  zramSwap = {
    enable = true;
    memoryPercent = 60;
  };

  networking.enableB43Firmware = false;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "25.11";
}
