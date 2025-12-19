{ userConfig, pkgs, ... }:
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
    # pavucontrol
    pwvucontrol
    alsa-utils # aplay etc..
    qjackctl
    qpwgraph # instead of qjackctl
  ];

  services.pulseaudio.enable = false;
  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;
    pulse.enable = false;

    extraConfig = {
      jack = {
        "10-latency" = {
          "jack.properties" = {
            "node.latency" = "128/48000";
          };
        };
      };
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
