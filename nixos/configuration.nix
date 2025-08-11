# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, hostname, unstable, userSettings, ... }:

{

  options = {
    my.arbitrary.option = lib.mkOption {
      type = lib.types.str;
      default = "stuff";
    };
  };

  config = {

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Experimental = true; # Show battery charge of Bluetooth devices
        };
      };
    };

    networking.hostName = hostname;
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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
    services.xserver.enable = true;
    # Enable KDE Plasma as the desktop environment.
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
    # Set SDD theme
    # services.displayManager.sddm.theme = "chili";
    # Enable the GNOME Desktop Environment.
    # services.xserver.displayManager.gdm.enable = true;
    # services.xserver.desktopManager.gnome.enable = true;

    # Hyprland
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "us,ru";
      model = "pc105";
      options = "grp:caps_toggle,grp_led:caps";
    };

    # Enable CUPS to print documents.
    services.printing.enable = false;

    # Enable sound with pipewire.
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    # Enable touchpad support (enabled default in most desktopManager).
    services.libinput.enable = true;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.${userSettings.username} = {
      isNormalUser = true;
      description = userSettings.name;
      extraGroups = [ "networkmanager" "wheel" ];
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      nix-output-monitor # beautify nix output
      nvd
      nh # nix helper
      curl
      htop
      git
      ripgrep
      fzf
      gcc
      unzip
      elinks
      python3
      killall
      home-manager
      kitty
      sddm-chili-theme
      libreoffice
      mtr
      traceroute
      nix-index
    ];

    programs.firefox.enable = true;
    programs.nix-ld.enable = true; # what's the heck it's this...
    programs.fish.enable = true;
    programs.zsh.enable = true;
    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };

    programs.nekoray = {
      enable = true;
      tunMode.enable = true;
      #   # tunMode.setuid = true;
    };
    services.resolved.enable = false; # nekoray
    networking.firewall.checkReversePath = "loose"; # nekoray

    # security.wrappers = {
    #   nekobox_core = {
    #     owner = "root";
    #     group = "root";
    #     source = "${pkgs.nekoray.nekobox-core}/bin/nekobox_core";
    #     capabilities = "cap_net_admin=ep";
    #   };
    # };

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };

    # List services that you want to enable:

    # Enable the OpenSSH daemon.
    services.openssh.enable = true;

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;

    nix.settings.experimental-features = [ "nix-command" "flakes" ];
  };
}
