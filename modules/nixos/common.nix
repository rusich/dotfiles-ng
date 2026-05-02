# Common nixos settings for both desktop and servers
# This module automatically loaded in all nixos configurations
{
  pkgs,
  hostname,
  lib,
  config,
  userConfig,
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

  # Bootloader how many configurations to show
  boot = {
    loader.systemd-boot.configurationLimit = 10;
  };

  # Networking
  networking.networkmanager.enable = true;
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
    package = pkgs.unstable.neovim-unwrapped;
  };

  programs.bash.shellAliases = vimAliases;
  programs.fish.shellAliases = vimAliases;
  programs.zsh.shellAliases = vimAliases;

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
      # lshw
      # iotop
    ]
    ++ config.my.nixosAndDarwinPackages;

}
