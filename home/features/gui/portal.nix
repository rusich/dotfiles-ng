# XDG desktop portal — Linux GUI plumbing. Enabled by the graphical bundle (or
# explicitly by users who run a graphical session without that bundle); servers
# must not enable it (useless on a headless host).
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.user.gui.portal;
in
{
  options.user.gui.portal.enable = lib.mkEnableOption "XDG desktop portal (Linux GUI)";

  config = lib.mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.common.default = [ "gtk" ];
    };
  };
}
