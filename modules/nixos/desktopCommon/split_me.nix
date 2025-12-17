# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  lib,
  pkgs,
  userConfig,
  hostname,
  ...
}:
{

  imports = [
  ];

  config = {

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

    # Enable the X11 windowing system.
    # services.xserver.enable = true;
    # Enable the GNOME Desktop Environment.
    # services.xserver.displayManager.gdm.enable = true;
    # services.xserver.desktopManager.gnome.enable = true;

    # SDDM
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;

    # Hyprland
    programs.hyprland = {
      enable = true;
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
      description = userConfig.username;
      extraGroups = [
        "networkmanager"
        "wheel"
        "jackaudio"
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
    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };

    programs.throne = {
      enable = true;
      tunMode.enable = true;
      #   # tunMode.setuid = true;
    };
    services.resolved.enable = false; # nekoray
    networking.firewall.checkReversePath = "loose"; # nekoray

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
    boot.loader.systemd-boot.configurationLimit = 10;

    # fwupd is a simple daemon allowing you to update some devices' firmware, including UEFI for several machines.
    services.fwupd.enable = true;

    # power management
    services.upower.enable = true;
    services.power-profiles-daemon.enable = true;

    # Disable gnome keyring for KeepassXC
    services.gnome.gnome-keyring = pkgs.lib.mkForce { enable = false; };
  };
}
