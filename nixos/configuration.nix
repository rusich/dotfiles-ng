# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  lib,
  pkgs,
  hostname,
  unstable,
  userSettings,
  inputs,
  ...
}:

{

  options = {
    my.arbitrary.option = lib.mkOption {
      type = lib.types.str;
      default = "stuff";
    };
  };

  config = {

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
      polkit_gnome
      gparted
      gimp
      kdePackages.kolourpaint
      inetutils
    ];

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
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage =
        inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      # package = unstable.hyprland;
      # portalPackage = unstable.xdg-desktop-portal-hyprland;
    };

    # Niri
    programs.niri.enable = true;

    # MangoWC
    programs.mango.enable = true;

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
      extraGroups = [
        "networkmanager"
        "wheel"
        "jackaudio"
        "libvirtd"
        "kvm"
        "input"
      ];
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    programs.corectrl.enable = true;
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

    security.polkit = {
      enable = true;
      extraConfig = ''

        /* Allow regular users to run corectrl as root */
        polkit.addRule(function(action, subject) {
            if ((action.id == "org.corectrl.helper.init" ||
                 action.id == "org.corectrl.helperkiller.init") &&
                subject.local == true &&
                subject.active == true &&
                subject.isInGroup("users")) {
                    return polkit.Result.YES;
            }
        });
      '';
    };

    systemd = {
      user.services.polkit-gnome-authentication-agent-1 = {
        description = "polkit-gnome-authentication-agent-1";
        wantedBy = [ "graphical-session.target" ];
        wants = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };
    };

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
      options = lib.mkDefault "--delete-older-than 7d";
    };
  };
}
