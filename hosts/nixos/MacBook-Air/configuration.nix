{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  # uid фиксируем явно, чтобы tmpfs-монтирования кэшей принадлежали владельцу.
  userUids = {
    rusich = 1000;
    bunny = 1001;
  };

  # Кэш Firefox каждого пользователя — в RAM, чтобы не точить SD.
  browserCacheMounts = lib.listToAttrs (
    lib.mapAttrsToList (user: uid: {
      name = "/home/${user}/.cache/mozilla";
      value = {
        device = "tmpfs";
        fsType = "tmpfs";
        options = [
          "mode=0700"
          "uid=${toString uid}"
          "gid=100"
          "size=512M"
          "nosuid"
          "nodev"
        ];
      };
    }) userUids
  );
in
{
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.apple-macbook-air-7
  ];

  # Enable custom modules
  nixos.profiles.desktop.enable = true;
  nixos.profiles.gnome.enable = true;

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
  # `rusich` is created by modules/nixos/common.nix (from primaryUser).
  users = {
    users = {
      # Основной пользователь этого ноутбука — Sakhaya (bunny).
      rusich.uid = 1000;
      bunny = {
        uid = 1001;
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
    # Не даём USB-ридеру карты автоусыпляться, иначе root пропадает
    "usbcore.autosuspend=-1"
    # Даём время ридеру подняться, в т.ч. после resume
    "usb-storage.delay_use=5"
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

  # Принудительно пробуждаем SD-ридер после выхода из сна.
  # ВНИМАНИЕ: ридер сидит на 2-3 (idVendor:idProduct = 05ac:8406),
  # раньше сервис бил в несуществующий 2-2 и молча ничего не делал.
  systemd.services.fix-sd-reader = {
    description = "Reinitialize SD card reader after resume";
    after = [ "systemd-suspend.service" ];
    wantedBy = [ "suspend.target" ];
    script = ''
      sleep 3
      # Ищем ридер по VID:PID = 05ac:8406, а не по жёсткому пути 2-3.
      for dev in /sys/bus/usb/devices/*; do
        [ -e "$dev/authorized" ] || continue
        [ "$(cat "$dev/idVendor" 2>/dev/null)" = "05ac" ] || continue
        [ "$(cat "$dev/idProduct" 2>/dev/null)" = "8406" ] || continue
        echo 0 > "$dev/authorized" 2>/dev/null || true
        sleep 2
        echo 1 > "$dev/authorized" 2>/dev/null || true
      done
      sleep 3
      for host in /sys/class/scsi_host/host*/scan; do
        [ -e "$host" ] || continue
        echo "- - -" > "$host" 2>/dev/null || true
      done
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = false;
    };
  };

  # --- Тюнинг для жизни на медленной SD за USB-ридером (BOT, queue_depth=1) ---
  # Ограничиваем «грязные» страницы абсолютными объёмами: по умолчанию ядро
  # копит сотни МБ (dirty_ratio=20% от 4 ГБ) и при массовом сбросе на медленную
  # карту блокирует всю систему. dirty_bytes и dirty_ratio взаимоисключающие.
  boot.kernel.sysctl = {
    "vm.dirty_bytes" = 32 * 1024 * 1024; # 32 МиБ — потолок для грязных страниц
    "vm.dirty_background_bytes" = 8 * 1024 * 1024; # фоновый сброс начинается раньше
    "vm.dirty_expire_centisecs" = 1500; # 15 с
    "vm.dirty_writeback_centisecs" = 300; # 3 с
    "vm.swappiness" = 10; # меньше трогать медленный swap на SD (zram приоритетнее)
    "vm.vfs_cache_pressure" = 60; # держим метаданные в кэше — меньше чтений
    "vm.page-cluster" = 0; # для zram: постраничное чтение swap вместо кластеров
  };

  # atime не обновляем — это лишние записи на карту.
  # commit=30 — реже журнальные синхронизации ext4 (меньше всплесков записи).
  # Плюс /var/tmp и кэши браузеров (browserCacheMounts) — в RAM.
  fileSystems = browserCacheMounts // {
    "/".options = [ "noatime" "commit=30" ];
    "/var/tmp" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [ "mode=1777" "size=512M" "nosuid" "nodev" ];
    };
  };

  # Помечаем карту как невращающуюся и задаём разумный read-ahead.
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="block", KERNEL=="sd[a-z]", ATTRS{idVendor}=="05ac", ATTRS{idProduct}=="8406", ATTR{queue/rotational}="0", ATTR{queue/read_ahead_kb}="1024", ATTR{queue/scheduler}="mq-deadline"
  '';

  # Логи в RAM (tmpfs), чтобы journald не точил SD постоянной записью.
  services.journald.extraConfig = ''
    Storage=volatile
    RuntimeMaxUse=64M
  '';

  # /tmp — в zram (сжатый RAM). Временные файлы больше не пишутся на SD.
  # ВАЖНО: zram-generator ждёт выражение от `ram` (в МиБ), а не литерал "1G" —
  # иначе парсер уходит в 4096× и падает с ENOMEM (vmalloc ~4 ТБ).
  boot.tmp.useZram = true;
  boot.tmp.cleanOnBoot = true;
  boot.tmp.zramSettings.zram-size = "ram / 4";

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
    "broadcom-sta-6.30.223.271-59-6.18.52"
  ];

  boot.blacklistedKernelModules = [ "b43" ];

  services.openssh.settings.PermitRootLogin = "yes";

  zramSwap = {
    enable = true;
    memoryPercent = 75;
  };

  networking.enableB43Firmware = false;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "25.11";
}
