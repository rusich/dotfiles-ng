{
  pkgs,
  unstable,
  stateVersion,
  lib,
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
  # amdgpu-stability-patch = pkgs.fetchpatch {
  #   name = "amdgpu-stability-patch";
  #   url = "https://github.com/torvalds/linux/compare/ffd294d346d185b70e28b1a28abe367bbfe53c04...SeryogaBrigada:linux:4c55a12d64d769f925ef049dd6a92166f7841453.diff";
  #   hash = "sha256-q/gWUPmKHFBHp7V15BW4ixfUn1kaeJhgDs0okeOGG9c=";
  # };
in
{
  imports = [ ];

  # Host-specific configuration
  console = {
    font = "ter-v24b";
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.amdgpu.initrd.enable = true;

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    tonelib-jam
    tonelib-metal
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
    protontricks
  ];

  services.xserver.videoDrivers = [ "amdgpu" ];
  # Host-specific packages
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.wivrn = {
    enable = true;
    openFirewall = true;
    defaultRuntime = true;
    package = unstable.wivrn;
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

  boot.supportedFilesystems = [ "ntfs" ];
  fileSystems."/mnt/Windows" = {
    device = "/dev/disk/by-uuid/01D8DB3D26BCE030";
    fsType = "ntfs-3g";
    options = [
      "users"
      "nofail"
      "rw"
      "uid=1000"
      "gid=100"
      "exec"
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = stateVersion; # Did you read the comment?
}
