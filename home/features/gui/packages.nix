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
  options.user.gui.packages.enable = lib.mkEnableOption "common GUI applications";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      whitesur-gtk-theme
      gnome-calculator
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

    # Applet runs via Remmina's own XDG autostart. The module's systemd unit
    # starts `remmina --icon` without a display env on niri and loops, so use
    # the standard option to turn it off.
    services.remmina = {
      enable = true;
      systemdService.enable = false;
    };
  };
}
