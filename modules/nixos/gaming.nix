{
  pkgs,
  config,
  lib,
  primaryUser,
  ...
}:
let
  cfg = config.nixos.profiles.gaming;
in
{
  options = {
    nixos.profiles.gaming.enable = lib.mkEnableOption "gaming software";
  };
  config = lib.mkIf cfg.enable {
    # adb (android-tools) and raw input-device access for the primary user.
    users.users.${primaryUser.username}.extraGroups = [
      "adbusers"
      "input"
    ];

    environment.systemPackages = with pkgs; [
      opencomposite
      wayvr
      mangohud
      mangojuice
      sidequest
      jstest-gtk
      # Lutris. Pull system Wine + winetricks into its FHS so Lutris can use
      # them directly (Wine version "System") instead of downloading the
      # Proton/umu/Sniper stack. Steam is enabled below, so keep steamSupport.
      (pkgs.lutris.override {
        extraPkgs = pkgs: [
          pkgs.wineWowPackages.stable
          pkgs.winetricks
        ];
      })
      # heroic
      protonup-qt
      protonup-rs
      # cartridges # GTK4 + Libadwaita game launcher
      #retroarch-full
      ryubing
      android-tools # need for qLoader
    ];

    programs.steam = {
      enable = true;
      package = pkgs.unstable.steam;
      gamescopeSession.enable = true;
      protontricks.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      extraCompatPackages = with pkgs; [ proton-ge-bin ];
    };

    programs.gamemode.enable = true;
    programs.gamescope.enable = true;

    services.wivrn = {
      enable = true;
      openFirewall = true;
      # defaultRuntime = true;
      # steam.importOXRRuntimes = true; # for Steam auto discover WivRN
    };

    programs.alvr = {
      enable = true;
      openFirewall = true;
      package = pkgs.alvr;
    };

    # Linux GPU Configuration Tool for AMD and NVIDIA
    # NOTE: If you are on an AMD GPU, it is recommended to enable overdrive mode by using hardware.amdgpu.overdrive.enable = true;
    services.lact.enable = true;

    # NOTE: repaced by LACT
    # Power profile management for gaming
    # programs.corectrl.enable = true;
    # security.polkit = {
    #   enable = true;
    #   extraConfig = ''
    #
    #     /* Allow regular users to run corectrl as root */
    #     polkit.addRule(function(action, subject) {
    #         if ((action.id == "org.corectrl.helper.init" ||
    #              action.id == "org.corectrl.helperkiller.init") &&
    #             subject.local == true &&
    #             subject.active == true &&
    #             subject.isInGroup("users")) {
    #                 return polkit.Result.YES;
    #         }
    #     });
    #   '';
    # };
  };
}
