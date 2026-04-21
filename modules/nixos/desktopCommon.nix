{
  pkgs,
  hostname,
  lib,
  userConfig,
  ...
}:
{
  # imports =
  #   with builtins;
  #   map (fn: ./${fn}) (
  #     filter (fn: fn != "default.nix" && fn != "disabled") (
  #       attrNames (readDir "${nixosModules}/desktopCommon")
  #     )
  #   );

  # APPIMAGE

  # environment.systemPackages = with pkgs; [
  #   appimage-run
  # ];
  #
  # # Exec AppImage files directly
  # boot.binfmt.registrations.appimage = {
  #   wrapInterpreterInShell = false;
  #   interpreter = "${pkgs.appimage-run}/bin/appimage-run";
  #   recognitionType = "magic";
  #   offset = 0;
  #   mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
  #   magicOrExtension = ''\x7fELF....AI\x02'';
  # };

  programs.appimage.enable = true;
  programs.appimage.binfmt = true;
  programs.appimage.package = pkgs.appimage-run.override {
    extraPkgs = pkgs: [
      pkgs.python312
    ];
  };

  # BLUETOOTH
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true; # Show battery charge of Bluetooth devices
        FastConnectable = true;
      };
      Policy = {
        AutoEnable = true;
      };
    };
  };

  services.blueman.enable = true;

  # DISPLQAY MANAGER

  environment.systemPackages = with pkgs; [
    gdm-settings
    acl
  ];

  # GDM
  services.displayManager.gdm = {
    enable = true;
  };

  # GDM augmentations

  # Доступ к /home/<username>/.face
  systemd.services.gdm-setup-acl = {
    description = "Set ACL permissions for GDM access to user directories";
    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" ];
    before = [ "display-manager.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "gdm-acl-setup" ''
        # Устанавливаем права на КОРНЕВЫЕ домашние папки (без -R!)
        for dir in /home/*/; do
          if [ -d "$dir" ]; then
            # Нормализуем путь (убираем trailing slash)
            dir="''${dir%/}"
            # Даем группе gdm право на выполнение (x) только для КОРНЕВОЙ папки
            ${pkgs.acl}/bin/setfacl -m group:gdm:x "$dir"
            # Даем группе gdm права на чтение и выполнение для .face файла
            # Альтернативные файлы аватарок
            for face_file in "/home/$USER/.face.icon" "/home/$USER/.icon"; do
              if [ -e "$face_file" ]; then
                ${pkgs.acl}/bin/setfacl -m group:gdm:rx "$face_file"
              fi
            done
          fi
        done
      '';
    };
  };

  # Доступ к /home/<username>/.face (запуск при выходе из сеанса пользователя)
  systemd.user.services.gdm-acl-on-logout = {
    description = "Set GDM ACL permissions on logout";
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      # Просто запускаем и сразу завершаемся
      ExecStart = "${pkgs.coreutils}/bin/true";
      # Этот скрипт выполнится при остановке graphical-session.target
      ExecStopPost = pkgs.writeShellScript "gdm-acl-logout" ''
        if [ -d "$HOME" ]; then
          echo "[$(date)] Setting GDM ACL for $USER on logout" | logger -t gdm-acl
          # Даем GDM доступ к домашней папке
          ${pkgs.acl}/bin/setfacl -m group:gdm:x "$HOME"
          # И к файлам аватарок
          for face_file in "$HOME/.face" "$HOME/.face.icon" "$HOME/.icon"; do
            if [ -e "$face_file" ]; then
              ${pkgs.acl}/bin/setfacl -m group:gdm:rx "$face_file"
            fi
          done
        fi
      '';
    };
  };

  # GNOME ONLINE ACCOUNTS

  # user config stored in
  # ../../home/contacts.nix
  # ../../home/calendar.nix

  programs.dconf.enable = true;
  services.gnome.evolution-data-server.enable = true;
  services.gnome.gnome-online-accounts.enable = true;

  # FROM SPLIT_ME.NIX

  networking.hostName = hostname;

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Yakutsk";

  # Select internationalisation properties.
  i18n.defaultLocale = "ru_RU.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };

  console = {
    earlySetup = true;
    font = lib.mkDefault "ter-v14b";
    packages = [ pkgs.terminus_font ];
    useXkbConfig = true;
  };

  # Niri
  programs.niri.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us,ru";
    model = "pc105";
    # options = "grp:caps_toggle,grp_led:caps";
    options = "grp:alt_shift_toggle,grp_led:caps";
  };

  # Enable CUPS to print documents.
  services.printing.enable = false;

  # Sound
  services.pipewire.enable = lib.mkDefault true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${userConfig.username} = {
    isNormalUser = true;
    description = userConfig.fullName;
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "kvm"
      "input"
      "adbusers"
      "qemu"
    ];
  };

  programs.nix-ld = {
    enable = true; # what's the heck it's this...
    libraries = with pkgs; [
      icu
    ];
  };
  programs.fish.enable = true;
  # programs.firefox.enable = true;

  programs.throne = {
    enable = true;
    tunMode.enable = true;
    #   # tunMode.setuid = true;
  };
  services.resolved.enable = false; # throne
  networking.firewall.checkReversePath = "loose"; # throne

  # Firewall
  networking.firewall.enable = true;
  # DPI youtube fix
  networking.firewall.extraCommands = ''
    # Разрешить ответные HTTPS пакеты (порт 443) от серверов
    # Без флага SYN (новые соединения инициируем мы)
    iptables -I nixos-fw 3 -p tcp --sport 443 -m tcp '!' --tcp-flags SYN SYN -j nixos-fw-accept

    # enable upnp client
    iptables -I nixos-fw  3 -p udp --sport 1900 -j nixos-fw-accept
  '';
  # Loggin for Debug firewall
  networking.firewall.logRefusedPackets = true; # Включить логирование ВСЕХ блокируемых пакетов
  networking.firewall.logRefusedUnicastsOnly = false;

  # enable upnp

  # DCS-world server
  networking.firewall.allowedTCPPorts = [ 10308 ];
  networking.firewall.allowedUDPPorts = [ 10308 ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # for WiVRn
  services.avahi = {
    enable = true;
    openFirewall = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };

  # Bootloader how many configurations to show
  boot = {
    loader.systemd-boot.configurationLimit = 10;
    plymouth = {
      enable = true;
    };
  };

  # fwupd is a simple daemon allowing you to update some devices' firmware, including UEFI for several machines.
  services.fwupd.enable = true;

  # power management
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  # Disable gnome keyring for KeepassXC
  services.gnome.gnome-keyring = pkgs.lib.mkForce { enable = false; };

}
