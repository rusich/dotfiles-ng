{
  userConfig,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.musnix.nixosModules.musnix
  ];

  # use automatic kernel and system optimizations
  # for realtime audio performance.
  # detailed explanation: https://github.com/musnix/musnix

  musnix.enable = true;
  # NOTE: Enabling this option will rebuild your kernel.
  # Description: If enabled, this option will apply the CONFIG_PREEMPT_RT patch to the kernel.
  musnix.kernel.realtime = false;

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
    # reaper - ardour fully replaces reaper, and its open source and free
    ardour
    gmetronome
    audacity
    # pavucontrol, not needed?
    pwvucontrol
    alsa-utils # aplay etc..
    qjackctl
    carla
    custom.patchance # TODO: it is nessesary? Or use only qjackctl and carla?
    qpwgraph # instead of qjackctl
    millisecond # Show tips for audio optimization for RealTime performance
    alsa-lib # For Ratatoule
    alsa-lib-with-plugins
    hydrogen # drums app
    drumgizmo # drums plugin
    unstable.tonelib-jam
    unstable.tonelib-metal
    unstable.tonelib-gfx
    # custom.tonelib-gfx
    custom.tonelib-grand-magus
    neural-amp-modeler-lv2
    # TODO: review plugins listed below
    jalv
    jalv-qt
    guitarix
    gxplugins-lv2
    zam-plugins
    calf
    lsp-plugins
    x42-plugins
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
    extraLv2Packages = [
      pkgs.lsp-plugins
    ];

    extraConfig = {
      pipewire = {
        "10-clock-rate" = {
          "context.properties" = {
            "default.clock.allowed-rates" = [
              # 44100
              48000
            ];
            "default.clock.rate" = 48000;
            "default.clock.quantum" = 512;
            "default.clock.min-quantum" = 64;
            "default.clock.max-quantum" = 2048;
          };
        };
      };
      jack = {
        "10-latency" = {
          "jack.properties" = {
            "node.latency" = "128/48000";
          };
        };
      };

      # pipewire-pulse = {
      # "10-some-file"...
      # };
      #
      # client = {
      # "10-some-file"...
      # };
    };
  };

  #alsa_card.usb-Line_6_POD_HD500-00
  # set PODHC500 pipewire audio profile to "Pro Audio"

  # # amixer -c "PODHD500" set Monitor 0%
  # systemd.services.disablePODHD500MONITORING = {
  #   enable = true;
  #   description = "Set Line6 POD HD500 Monitoring Level to 0%";
  #   wantedBy = [ "multi-user.target" ];
  #   serviceConfig = {
  #     ExecStart = "${pkgs.alsa-utils}/bin/amixer -c \"PODHD500\" set Monitor 0%";
  #     Restart = "always"; # Optional: restart the service if it fails
  #   };
  # };

}
