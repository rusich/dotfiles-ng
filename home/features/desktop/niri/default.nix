{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.user.desktop.niri;
in
{
  options.user.desktop.niri.enable = lib.mkEnableOption "niri compositor";

  config = lib.mkIf cfg.enable {
    # required packages
    home.packages = with pkgs; [
      # 0.8.3 fixes Steam popups closing instantly (override-redirect focus).
      unstable.xwayland-satellite
    ];

    # Map the niri config files to standard location
    home.file = {
      # out-of-store: noctalia writes generated themes into this dir.
      ".config/niri".source =
        config.lib.file.mkOutOfStoreSymlink config.homeModulesPath + "/features/desktop/niri/config";
    };
  };
}
