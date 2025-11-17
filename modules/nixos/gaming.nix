{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    opencomposite
    wlx-overlay-s
    mangohud
    sidequest
    jstest-gtk
    protonup-qt
  ];

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    protontricks.enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
  };

  programs.gamemode.enable = true;
  programs.gamescope.enable = true;
  programs.adb.enable = true; # for WiVRN

  services.wivrn = {
    enable = true;
    openFirewall = true;
    defaultRuntime = true;
    package = pkgs.unstable.wivrn;
    steam.importOXRRuntimes = true; # for Steam auto discover WivRN
  };

  programs.alvr = {
    enable = true;
    openFirewall = true;
    package = pkgs.alvr;
  };

  # Power profile management for gaming
  programs.corectrl.enable = true;
  security.polkit = {
    enable = true;
    extraConfig = ''

      /* Allow regular users to run corectrl as root */
      polkit.addRule(function(action, subject) {
          if ((action.id == "org.corectrl.helper.init" ||
               action.id == "org.corectrl.helperkiller.init") &&
              subject.local == true &&
              subject.active == true &&
              subject.isInGroup("users")) {
                  return polkit.Result.YES;
          }
      });
    '';
  };
}
