{
  config,
  lib,
  ...
}:
let
  cfg = config.user.gui.onlyoffice;
in
{
  options.user.gui.onlyoffice.enable = lib.mkEnableOption "onlyoffice";

  config = lib.mkIf cfg.enable {
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
