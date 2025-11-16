{
  pkgs,
  lib,
  config,
  nixosModules,
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
  # amdgpu-stability-patch = pkgs.fetchpatch {
  #   name = "amdgpu-stability-patch";
  #   url = "https://github.com/torvalds/linux/compare/ffd294d346d185b70e28b1a28abe367bbfe53c04...SeryogaBrigada:linux:4c55a12d64d769f925ef049dd6a92166f7841453.diff";
  #   hash = "sha256-q/gWUPmKHFBHp7V15BW4ixfUn1kaeJhgDs0okeOGG9c=";
  # };
in
{
  # Move this to common config?
  system.stateVersion = "25.05";

  imports = [
    ./hardware-configuration.nix
    "${nixosModules}/plasma6.nix"
    "${nixosModules}/split_me.nix"
    "${nixosModules}/gnome-online-accounts.nix"
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
    unstable.tonelib-jam
    unstable.tonelib-metal
    unstable.tonelib-gfx
    unstable.reaper
    mangohud
    qjackctl
    gmetronome
    guitarix
    audacity
    lmstudio
    sidequest
    # librsvg # wivrn
    # cairo # librsvg, wivrn
    opencomposite
    wlx-overlay-s
    virt-manager
    jstest-gtk
    quickemu
    quickgui
    spice
    spice-gtk
    virt-viewer
    gamemode
    gamescope
    protonup-qt
    android-tools
    cifs-utils # for smb share mount
    wlr-randr
    xorg.xrandr
    anydesk
  ];

  services.xserver.videoDrivers = [ "amdgpu" ];
  # Host-specific packages
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.steam.protontricks.enable = true;
  programs.gamemode.enable = true;
  # programs.steam.extraCompatPackages = with pkgs; [ proton-ge-bin ];

  programs.adb.enable = true;

  services.wivrn = {
    enable = true;
    openFirewall = true;
    defaultRuntime = true;
    package = pkgs.unstable.wivrn;
  };

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

  # audio override
  security.rtkit.enable = true;

  # Disable Pulseaudio because Pipewire is used.
  # hardware.pulseaudio.enable = lib.mkForce false;
  # sound.enable = false; # Only meant for ALSA-based configurations.
  # hardware.alsa.enable = false;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    wireplumber = {
      enable = true;
      package = pkgs.wireplumber;
    };
  };
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
  users.users.zaychik = {
    isNormalUser = true;
    description = "Sakhaya Sergina";
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
    device = "/dev/disk/by-uuid/8432d060-bbd1-48e2-b45a-a7c27239c39c";
    fsType = "ext4";
    options = [
      "defaults"
      "nofail"
      "noatime"
      "users"
      "exec"
      "rw"
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

  virtualisation = {
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
  };

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

  # ${pkgs.wlr-randr}/bin/wlr-randr --output DP-2 --off
  # ${pkgs.xrandr}/bin/xrandr --output DP-2 --left-of DP-1
  # ${pkgs.wlr-randr}/bin/wlr-randr --output DP-1 --pos 0,0 --output DP-2 --pos 2560,0

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
}
