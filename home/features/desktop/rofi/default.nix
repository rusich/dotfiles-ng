{
  config,
  lib,
  ...
}:
let
  cfg = config.features.desktop.rofi;
in
{
  options.features.desktop.rofi.enable = lib.mkEnableOption "rofi launcher";

  config = lib.mkIf cfg.enable {
    home.file = {
      # out-of-store: noctalia writes generated themes into this dir.
      ".config/rofi".source =
        config.lib.file.mkOutOfStoreSymlink config.homeModulesPath + "/features/desktop/rofi/config";
    };
  };
}
