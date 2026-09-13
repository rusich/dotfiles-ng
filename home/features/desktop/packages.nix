{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.user.desktop.packages;
in
{
  options.user.desktop.packages.enable = lib.mkEnableOption "Linux desktop applications";

  config = lib.mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    programs.alacritty.enable = true;

    home.packages = with pkgs; [
      whitesur-icon-theme
      nwg-look
      pamixer
      networkmanagerapplet
      unetbootin
      kdePackages.breeze
      playerctl
      decibels
      calibre
      grimblast
      vlc
      wl-clipboard
      chatbox
      loupe
      papers
      custom.freelib
    ];
  };
}
