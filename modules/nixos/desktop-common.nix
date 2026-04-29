{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.nixosModules.desktop-common;
in
{
  options = {
    my.nixosModules.desktop-common.enable = lib.mkEnableOption "unified configuration for desktop computer, like: GUI Software, bluetooth, sound, etc";
  };
  config = lib.mkIf cfg.enable {

    # Enable some useful desktop modules
    my.nixosModules.GDM.enable = true;

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

    programs.dconf.enable = true;
    services.gnome.evolution-data-server.enable = true;
    services.gnome.gnome-online-accounts.enable = true;

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

    # Bootloader enable plymouth
    boot = {
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
    # services.gnome.gnome-keyring = pkgs.lib.mkForce { enable = false; };

    # packaages

    environment.systemPackages = with pkgs; [
      libreoffice
      kitty
      hunspell
      hunspellDicts.en_US
      hunspellDicts.ru_RU
      gparted
      gimp
      nextcloud-client
      # Nautilus + dependencies
      nautilus
      nautilus-python # for nextcloud integration
      nautilus-open-any-terminal
      firefox
      # misc
      xkill
    ];

    # Let nautilus find extensions
    environment.sessionVariables.NAUTILUS_4_EXTENSION_DIR = "${config.system.path}/lib/nautilus/extensions-4";
    environment.pathsToLink = [
      "/share/nautilus-python/extensions"
    ];

  };
}
