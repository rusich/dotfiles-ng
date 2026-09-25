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

  # thermald отключён: на Apple-железе он не знает машину и может лишний
  # раз резать частоты. Управлением вентилятором заведует mbpfan
  # (включается модулем apple-macbook-air-7 из nixos-hardware).
  services.thermald.enable = false;

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
    # s2idle вместо deep (S3). Проверено на обоих носителях: Apple-ридер
    # (SD) с корневой ФС при resume отваливался (`usb 2-3: USB disconnect`
    # → ext4 ro → краш), а AGI-флешка (текущий root) s2idle переживает —
    # USB не переподключается, root жив. Оставляем s2idle.
    "mem_sleep_default=s2idle"
    "i915.enable_psr=0"
    "pcie_aspm=off"
    # Не даём USB-носителю автоусыпляться, иначе root пропадает
    "usbcore.autosuspend=-1"
    # Даём USB-устройствам время подняться, в т.ч. после resume
    "usb-storage.delay_use=5"
    # Устройство для гибернации (sda3 активируется вручную, см. swapDevices)
    "resume=/dev/sda3"
    "resume_wait=10"
    # Корректное восстановление после S3
    "acpi_sleep=nonvs"
    # "acpi_osi=!Windows 2013"
  ];

  # Устройство для гибернации
  boot.resumeDevice = "/dev/sda3";

  # Отключаем заморозку сессий через Service-файл systemd-suspend
  systemd.services.systemd-suspend = {
    serviceConfig = {
      Environment = "SYSTEMD_SLEEP_FREEZE_USER_SESSIONS=false";
    };
  };

  # Пересканирование шины SCSI/USB после пробуждения.
  #
  # ИСТОРИЯ: раньше здесь был сервис `fix-sd-reader`, который по
  # `wantedBy = suspend.target` деавторизовал USB-устройство (echo 0 >
  # authorized) — а на нём лежала КОРНЕВАЯ ФС. Деавторизация корневого
  # устройства обрывала root → I/O errors → краш после пробуждения.
  # Сервис удалён.
  #
  # Теперь — безопасный sleep-hook (systemd-sleep, /etc/systemd/system-sleep):
  # НЕ трогает `authorized` и НЕ деавторизует устройство. Только пересканирует
  # хосты, что заставляет ядро заново обнаружить устройство, если оно
  # отвалилось при засыпании. Если носитель пережил сон — операция безвредна.
  environment.etc."systemd/system-sleep/rescan-sd-reader.sh" = {
    mode = "0755";
    text = ''
      #!/bin/sh
      case "$1" in
        post)
          sleep 2
          for host in /sys/class/scsi_host/host*/scan; do
            [ -e "$host" ] || continue
            echo "- - -" > "$host" 2>/dev/null || true
          done
          ;;
      esac
      exit 0
    '';
  };

  # --- Тюнинг для жизни на медленном USB-носителе (BOT, queue_depth=1) ---
  # Актуально и для AGI-флешки: запись быстрее SD, но всё ещё не SSD.
  # Ограничиваем «грязные» страницы абсолютными объёмами: по умолчанию ядро
  # копит сотни МБ (dirty_ratio=20% от 4 ГБ) и при массовом сбросе на медленный
  # носитель блокирует всю систему. dirty_bytes и dirty_ratio взаимоисключающие.
  boot.kernel.sysctl = {
    "vm.dirty_bytes" = 32 * 1024 * 1024; # 32 МиБ — потолок для грязных страниц
    "vm.dirty_background_bytes" = 8 * 1024 * 1024; # фоновый сброс начинается раньше
    "vm.dirty_expire_centisecs" = 1500; # 15 с
    "vm.dirty_writeback_centisecs" = 300; # 3 с
    # Умеренный swappiness: не заливаем zram проактивно холодной анонкой,
    # оставляя запас под пики (напр. сборку парсеров). Диск-своп отключён,
    # поэтому вытеснение page cache на медленный своп уже не грозит.
    "vm.swappiness" = 60;
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

  # Помечаем USB-носители как невращающиеся и задаём разумный read-ahead.
  # Два правила: Apple SD-ридер (05ac:8406) и AGI-флешка (24a9:205a).
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="block", KERNEL=="sd[a-z]", ATTRS{idVendor}=="05ac", ATTRS{idProduct}=="8406", ATTR{queue/rotational}="0", ATTR{queue/read_ahead_kb}="1024", ATTR{queue/scheduler}="mq-deadline"
    ACTION=="add|change", SUBSYSTEM=="block", KERNEL=="sd[a-z]", ATTRS{idVendor}=="24a9", ATTRS{idProduct}=="205a", ATTR{queue/rotational}="0", ATTR{queue/read_ahead_kb}="1024", ATTR{queue/scheduler}="mq-deadline"
  '';

  # Логи — persistent с малым лимитом: сохраняем логи зависаний,
  # но не раздуваем запись на SD.
  services.journald.extraConfig = ''
    Storage=persistent
    SystemMaxUse=32M
    RuntimeMaxUse=32M
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
    # 100% от RAM: больше «ёмкость» свопа до упора → earlyoom/OOM реже
    # срабатывают на тяжёлых разовых задачах. Память не резервируется,
    # тратится только под реально сжатые данные.
    memoryPercent = 100;
  };

  # sda3 (та же SD-карта) как обычный swap — только во вред: когда zram
  # переполняется, ядро сливает анонку на 5 МБ/с карту, и система встаёт
  # (в тесте ушло ~2.4 ГБ на sda3 при io_full до 88%). Помечаем его
  # `noauto`: в обычной работе диск-своп не активен (свопимся только в zram),
  # а гибернация остаётся возможной — активировать вручную перед сном:
  #   sudo swapon /dev/disk/by-uuid/d237160e-7b7a-436c-81c7-dc3451f2d789
  #   systemctl hibernate
  swapDevices = lib.mkForce [
    {
      device = "/dev/disk/by-uuid/d237160e-7b7a-436c-81c7-dc3451f2d789";
      options = [ "noauto" ];
    }
  ];

  # Страховка от «завис вместо OOM»: earlyoom убивает самого прожорливого,
  # когда и доступная память, и свободный своп почти исчерпаны. Браузер и
  # композитор защищены через --avoid, сборщики/установщики — в приоритете
  # на убийство. Порог 5% — срабатывает только в крайнем случае.
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;
    freeSwapThreshold = 5;
    extraArgs = [
      "--avoid" "(firefox|firefox-bin|Isolated[[:space:]]Web[[:space:]]Co|Web[[:space:]]Content|WebExtensions|niri|gnome-shell|Xwayland|Xorg)"
      "--prefer" "(cc1|cc1plus|gcc|clang|rustc|cargo|node|npm|yarn|pnpm|tar|unzip|7z|zstd|xz|nvim|git)"
    ];
  };

  # Изоляция ресурсов пользовательской сессии. Композитор (niri) живёт в
  # session.slice, приложения (терминалы, сборки, браузер) — в app.slice.
  # Ограничиваем память приложений, чтобы тяжёлые сборки/установки не утянули
  # всю RAM и не уронили сессию в memory-pressure ливлок. MemoryHigh только
  # притормаживает (не убивает) — браузер не вылетит. Плюс приоритет CPU
  # композитору, чтобы UI не голодал под нагрузкой.
  systemd.user.slices.app.sliceConfig = {
    MemoryHigh = "2300M";
    CPUWeight = "50";
  };
  systemd.user.slices.session.sliceConfig = {
    CPUWeight = "300";
    # Гарантируем память композитору: его страницы не вытесняются/не свопятся,
    # поэтому UI (мышь, окна) остаётся отзывчивым даже под тяжёлой нагрузкой.
    MemoryMin = "200M";
    MemoryLow = "400M";
  };

  networking.enableB43Firmware = false;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "25.11";
}
