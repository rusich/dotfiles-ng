{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.desktop.niri;
in
{
  options.features.desktop.niri.enable = lib.mkEnableOption "niri compositor";

  config = lib.mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    # required packages
    home.packages = with pkgs; [
      xwayland-satellite
    ];

    # Map the niri config files to standard location
    home.file = {
      # out-of-store: noctalia writes generated themes into this dir.
      ".config/niri".source =
        config.lib.file.mkOutOfStoreSymlink config.homeModulesPath + "/features/desktop/niri/config";
    };
  };
}
