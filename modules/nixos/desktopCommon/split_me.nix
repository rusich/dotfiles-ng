# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  lib,
  pkgs,
  userConfig,
  inputs,
  outputs,
  hostname,
  ...
}:

{

  imports = [
  ];

  options = {
    my.arbitrary.option = lib.mkOption {
      type = lib.types.str;
      default = "stuff";
    };
  };

  config = {

    nixpkgs = {
      overlays = [
        outputs.overlays.unstable-packages
      ];

      config = {
        allowUnfree = true;
      };
    };

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      pkg-config
      openssl
      nix-output-monitor # beautify nix output
      nvd
      nh # nix helper
      curl
      wget
      htop
      btop
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
      sddm-astronaut
      sddm-sugar-dark
      libreoffice
      hunspell
      hunspellDicts.en_US
      hunspellDicts.ru_RU
      mtr
      traceroute
      nix-index
      lm_sensors
      pavucontrol
      # polkit_gnome
      gparted
      gimp
      inetutils
      nextcloud-client
      nautilus
      nautilus-python
      nautilus-open-any-terminal
      # kde package
      kdePackages.dolphin
      kdePackages.dolphin-plugins
      kdePackages.qtsvg # for dolphin
      kdePackages.kio-extras
    ];

    # services.noctalia-shell.enable = true;

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

    # Enable sound with pipewire.
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      jack.enable = lib.mkDefault true;
    };

    # Disable Pulseaudio because Pipewire is used.
    # hardware.pulseaudio.enable = lib.mkForce false;
    # sound.enable = false; # Only meant for ALSA-based configurations.
    # hardware.alsa.enable = false;

    # services.jack = {
    #   jackd.enable = true;
    #   # support ALSA only programs via ALSA JACK PCM plugin
    #   alsa.enable = false;
    #   # support ALSA only programs via loopback device (supports programs like Steam)
    #   loopback = {
    #     enable = true;
    #     # buffering parameters for dmix device to work with ALSA only semi-professional sound programs
    #     #dmixConfig = ''
    #     #  period_size 2048
    #     #'';
    #   };
    # };
    #

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

    # Allow unfree packages

    programs.firefox.enable = true;
    programs.nix-ld = {
      enable = true; # what's the heck it's this...
      libraries = with pkgs; [
        icu
      ];
    };
    programs.fish.enable = true;
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
    networking.firewall.allowedTCPPorts = [ 10308 ];
    networking.firewall.allowedUDPPorts = [ 10308 ];

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

    # services.devmon.enable = true;
    services.gvfs.enable = true;
    services.udisks2.enable = true;

    # systemd = {
    #   user.services.polkit-gnome-authentication-agent-1 = {
    #     description = "polkit-gnome-authentication-agent-1";
    #     wantedBy = [ "graphical-session.target" ];
    #     wants = [ "graphical-session.target" ];
    #     after = [ "graphical-session.target" ];
    #     serviceConfig = {
    #       Type = "simple";
    #       ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
    #       Restart = "on-failure";
    #       RestartSec = 1;
    #       TimeoutStopSec = 10;
    #     };
    #   };
    # };

    # for WiVRn
    services.avahi = {
      enable = true;
      openFirewall = true;
      publish = {
        enable = true;
        userServices = true;
      };
    };

    # Exec AppImage files directly
    boot.binfmt.registrations.appimage = {
      wrapInterpreterInShell = false;
      interpreter = "${pkgs.appimage-run}/bin/appimage-run";
      recognitionType = "magic";
      offset = 0;
      mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
      magicOrExtension = ''\x7fELF....AI\x02'';
    };

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    # cleanup system automatically
    nix.gc = {
      automatic = lib.mkDefault true;
      dates = "daily";
      options = lib.mkDefault "--delete-older-than 7d";
    };

    # Nix store optimisation
    nix.settings.auto-optimise-store = true;
    nix.optimise = {
      automatic = true;
      dates = [ "daily" ];
    };

    # Automatic upgrading
    system.autoUpgrade = {
      enable = true;
      dates = "weekly";
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
