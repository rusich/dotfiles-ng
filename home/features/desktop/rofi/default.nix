{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.user.desktop.rofi;
in
{
  options.user.desktop.rofi.enable = lib.mkEnableOption "rofi launcher";

  config = lib.mkIf cfg.enable {
    home.file = {
      # out-of-store: noctalia writes generated themes into this dir.
      ".config/rofi".source =
        config.lib.file.mkOutOfStoreSymlink config.homeModulesPath + "/features/desktop/rofi/config";
    };

    home.packages = [
      pkgs.rofi
    ];
  };
}
