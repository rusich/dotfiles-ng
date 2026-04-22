{
  pkgs,
  config,
  ...
}:
let
  # custom amdgpu kernel module with some patches
  amdgpu-kernel-module = pkgs.callPackage ./amdgpu-kernel-module.nix {
    # Make sure the module targets the same kernel as your system is using.
    kernel = config.boot.kernelPackages.kernel;
  };
  amd-gpu-ignore-ctx-privileges-patch = pkgs.fetchpatch {
    name = "cap_sys_nice_begone.patch";
    url = "https://github.com/Frogging-Family/community-patches/raw/master/linux61-tkg/cap_sys_nice_begone.mypatch";
    hash = "sha256-Y3a0+x2xvHsfLax/uwycdJf3xLxvVfkfDVqjkxNaYEo=";
  };
in
{
  # Move this to common config?
  system.stateVersion = "25.05";

  imports = [
    ./hardware-configuration.nix
    # Common for desktops
    ../../../modules/nixos/desktopCommon.nix
    ../../../modules/nixos/commonPackages.nix
    ../../../modules/nixos/desktopPackages.nix
    # Optional
    ../../../modules/nixos/desktopPackages.nix
    ../../../modules/nixos/optional/gaming.nix
    ../../../modules/nixos/optional/DAW.nix
    ../../../modules/nixos/optional/gamedev.nix
    ../../../modules/nixos/optional/virt/host.nix
    ../../../modules/nixos/optional/gnome.nix
  ];

  # Host-specific configuration
  console = {
    font = "ter-v24b";
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.amdgpu.initrd.enable = true;

  hardware.cpu.amd.updateMicrocode = true;

  environment.systemPackages = with pkgs; [
    lmstudio
    wlr-randr
    xorg.xrandr
    anydesk
  ];

  services.xserver.videoDrivers = [ "amdgpu" ];

  # for corectrl full features
  boot.kernelParams = [ "amdgpu.ppfeaturemask=0xffffffff" ];

  boot.extraModulePackages = [
    (amdgpu-kernel-module.overrideAttrs (_: {
      patches = [
        # amdgpu-stability-patch
        amd-gpu-ignore-ctx-privileges-patch
        # ./patches/amdgpu-stability-patch.diff
      ];
    }))
  ];

  services.udev = {
    enable = true;
    extraRules = ''
      # Force gamepad id's in order for IL-2 and War Thunder to work correctly
      # Defender COBRA M5 USB Joystick
      SUBSYSTEM=="input", ATTRS{idVendor}=="11c0", ATTRS{idProduct}=="5603", SYMLINK+="input/js0", MODE="0666"
      # ThrustMaster, Inc. HOTAS Warthog Joystick
      SUBSYSTEM=="input", ATTRS{idVendor}=="044f", ATTRS{idProduct}=="0402", SYMLINK+="input/js1", MODE="0666"
      # ThrustMaster, Inc. HOTAS Warthog Throttle
      SUBSYSTEM=="input", ATTRS{idVendor}=="044f", ATTRS{idProduct}=="0404", SYMLINK+="input/js2", MODE="0666"
    '';
  };

  users.users.zaychik = {
    isNormalUser = true;
    description = "Sakhaya Sergina";
    extraGroups = [ "networkmanager" ];
  };

  users.users.busya = {
    isNormalUser = true;
    description = "Kristina Sergina";
    extraGroups = [ "networkmanager" ];
  };

  boot.supportedFilesystems = [
    "ntfs"
    "btrfs"
    "exfat"
    "zfs"
  ];

  networking.hostId = "69cfd900"; # for zfs support

  fileSystems."/mnt/nvme500g/wt" = {
    device = "/dev/disk/by-uuid/2B52D7E135A3AB06";
    fsType = "ntfs";
    options = [
      "defaults"
      "nofail"
      "noatime"
      "users"
      "exec"
      "rw"
      "uid=1000"
      "gid=100"
      # "umask=000"
      # "nosuid"
      # "nodev"
      # "x-gfvs-show"
    ];
  };

  fileSystems."/mnt/nvme500g/dcs" = {
    device = "/dev/disk/by-uuid/C0E4-C1F9";
    fsType = "exfat";
    # device = "/dev/disk/by-uuid/8432d060-bbd1-48e2-b45a-a7c27239c39c";
    # fsType = "ext4";
    options = [
      "defaults"
      "nofail"
      "noatime"
      "users"
      "exec"
      "rw"
      "uid=1000"
      "gid=100"
    ];
  };

  fileSystems."/mnt/windows" = {
    device = "/dev/disk/by-uuid/01DC2D1572919960";
    fsType = "ntfs";
    options = [
      "defaults"
      "nofail"
      "noatime"
      "users"
      "exec"
      "rw"
      "uid=1000"
      "gid=100"
      # "umask=000"
      # "nosuid"
      # "nodev"
      # "x-gfvs-show"
    ];
  };

  fileSystems."/mnt/truenas_public" = {
    device = "//192.168.5.3/public";
    fsType = "cifs";
    options =
      let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
      in
      [ "${automount_opts},credentials=/etc/smb-secrets,uid=1000,gid=100" ];
  };

  fileSystems."/mnt/keenetic_opkg" = {
    device = "//192.168.5.1/opkg";
    fsType = "cifs";
    options =
      let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
      in
      [ "${automount_opts},username=root,domain=WORKGROUP,uid=1000,gid=100" ];
  };

  environment.etc.smb-secrets.text = ''
    username=guest
    password=guest
  '';
  # fileSystems."/mnt/SteamLibAS/SteamLibrary/steamapps/compatdata" = {
  #   device = "/home/rusich/Games/SteamLibrary/steamapps/compatdata/";
  #   depends = [ "/mnt/SteamLibAS" ];
  #   fsType = "none";
  #   options = [
  #     "bind"
  #     "rw"
  #     "uid=1000"
  #     "gid=100"
  #     "umask=000"
  #   ];
  # };

  boot.extraModprobeConfig = ''
    options kvm_intel nested=1
    options kvm_intel emulate_invalid_guest_state=0
    options kvm ignore_msrs=1
  '';

  # # Создаем скрипт для настройки дисплеев
  # environment.etc."sddm/display_setup.sh" = {
  #   text = ''
  #     #!/bin/sh
  #     sleep 3  # Ждем инициализации Wayland
  #
  #     # Меняем дисплеи местами (пример)
  #     # wlr-randr --output DP-2 --left-of DP-1
  #     wlr-randr --output DP-2 --pos 0,0 --output DP-1 --pos 2560,0
  #     xrandr --output DP-2 --pos 0,0 --output DP-1 --pos 2560,0
  #   '';
  #   mode = "0755";
  # };

  services.displayManager.sddm = {
    setupScript = ''
      wlr-randr --output DP-2 --toggle
    '';
  };

  # # # DPI fixes on homelan via nfqws2-keenetic
  # boot.kernel.sysctl = {
  #   # "net.ipv4.tcp_timestamps" = 0;
  #   "net.ipv4.tcp_sack" = 0;
  #   # "net.ipv4.tcp_dsack" = 0;
  #   #   # if rebuild slow try this ->
  #   #   # "net.ipv4.tcp_fastopen" = 3;
  #   #   # "net.ipv4.tcp_mtu_probing" = 1;
  # };

  # Defaults is:
  # net.ipv4.tcp_sack = 1
  # net.ipv4.tcp_timestamps = 1
  # net.ipv4.tcp_fastopen = 1
  # net.ipv4.tcp_mtu_probing = 0

  # ${pkgs.wlr-randr}/bin/wlr-randr --output DP-2 --off
  # ${pkgs.xrandr}/bin/xrandr --output DP-2 --left-of DP-1
  # ${pkgs.wlr-randr}/bin/wlr-randr --output DP-1 --pos 0,0 --output DP-2 --pos 2560,0
}
