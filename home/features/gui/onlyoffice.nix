{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.gui.onlyoffice;
in
{
  options.features.gui.onlyoffice.enable = lib.mkEnableOption "onlyoffice";

  config = lib.mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    programs.onlyoffice = {
      enable = true;
      # settings = ''
      #   UITheme = "theme-contrast-dark";
      #   editorWindowMode = false;
      #   forcedRtl = false;
      #   maximized = true;
      #   titlebar = "custom";
      # '';
    };
  };
}
