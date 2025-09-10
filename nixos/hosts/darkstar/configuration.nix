{
  pkgs,
  unstable,
  stateVersion,
  lib,
  ...
}:

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
    # dotnet-sdk_8
    # dotnet-runtime_8
    # wine-wayland
    # winetricks
    # dotnetCorePackages.runtime_9_0-bin
    # dotnetCorePackages.sdk_9_0-bin
    # dotnetPackages.Nuget
    # icu
    # skia
    # fontconfig
    # freetype
  ];

  services.xserver.videoDrivers = [ "amdgpu" ];
  # Host-specific packages
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;
  services.desktopManager.plasma6.enable = true;

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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = stateVersion; # Did you read the comment?
}
