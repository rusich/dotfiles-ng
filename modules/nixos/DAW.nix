{
  userConfig,
  pkgs,
  lib,
  ...
}:
{

  # Required groups
  users.users.${userConfig.username} = {
    isNormalUser = true;
    description = userConfig.username;
    extraGroups = [
      "jackaudio"
      "audio"
    ];
  };

  environment.systemPackages = with pkgs; [
    unstable.tonelib-jam
    unstable.tonelib-metal
    unstable.tonelib-gfx
    ardour
    reaper
    gmetronome
    guitarix
    audacity
    pavucontrol
    pwvucontrol
    alsa-utils # aplay etc..
    qjackctl
    qpwgraph # instead of qjackctl
    millisecond # Show tips for audio optimization for RealTime performance
    carla
    lsp-plugins
    neural-amp-modeler-lv2
    patchance
    python313Packages.legacy-cgi
  ];

  services.pulseaudio.enable = false;
  # Enable sound with pipewire.
  security.rtkit.enable = true; # PW use RT scheduler for increase performance
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;
    pulse.enable = true;

    # TODO: Temporary disabled for learning purpiose (configs in home/.config/pipewire/pipewire.conf)
    # extraConfig = {
    #   jack = {
    #     "10-latency" = {
    #       "jack.properties" = {
    #         "node.latency" = "128/48000";
    #       };
    #     };
    #   };
    # };
  };

  # amixer -c "PODHD500" set Monitor 0%
  systemd.services.disablePODHD500MONITORING = {
    enable = true;
    description = "Set Line6 POD HD500 Monitoring Level to 0%";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.alsa-utils}/bin/amixer -c \"PODHD500\" set Monitor 0%";
      Restart = "always"; # Optional: restart the service if it fails
    };
  };

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
}
