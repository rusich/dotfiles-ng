# Common nixos settings for both desktop and servers
# This module automatically loaded in all nixos configurations
{
  pkgs,
  hostname,
  lib,
  config,
  ...
}:
let
  vimAliases = {
    "v" = "nvim";
    "vim" = "nvim";
    "vi" = "nvim";
  };
in
{

  programs.fish.enable = true;

  # Bootloader: keep the boot menu bounded. On systemd-boot this also prunes
  # old generations; on GRUB it keeps the kernels copied into /boot bounded.
  boot = {
    loader.systemd-boot.configurationLimit = 5;
    loader.grub.configurationLimit = 5;
  };

  # nh clean replaces the built-in nix-gc on NixOS: it keeps the last N
  # generations AND everything younger than the period, across system,
  # per-user and XDG (home-manager) profiles, then runs `nix store gc`.
  nix.gc.automatic = lib.mkForce false;
  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      dates = "daily";
      extraArgs = "--keep 5 --keep-since 14d";
    };
  };

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      icu
    ];
  };

  # Networking
  networking.hostName = hostname;
  environment.etc.smb-secrets.text = ''
    username=guest
    password=guest
  '';

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Yakutsk";

  # Fix hardware clock on dualboot
  time.hardwareClockInLocalTime = true;

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

  # Automatic upgrading
  system.autoUpgrade = {
    enable = false;
    allowReboot = false;
    # flake = "/path/to/flake";
    dates = "weekly";
  };

  # Neovim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.fish.shellAliases = vimAliases;

  environment.systemPackages =
    with pkgs;
    [
      gcc
      python3
      home-manager
      # misc
      traceroute
      lm_sensors
      cifs-utils
      # to explore:
      lshw
      iotop
    ]
    ++ config.packages.common;

}
