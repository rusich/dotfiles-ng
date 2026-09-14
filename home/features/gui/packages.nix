{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.user.gui.packages;
in
{
  options.user.gui.packages.enable = lib.mkEnableOption "common cross-platform GUI applications";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      whitesur-gtk-theme
      gnome-calculator
      discord
      showtime
      mpv
      telegram-desktop
      # fonts and desktop libs previously in the base set
      nerd-fonts.iosevka
      nerd-fonts.iosevka-term
      nerd-fonts.fantasque-sans-mono
      libsecret
      libnotify
    ];

    services.remmina.enable = true;
  };
}
