{
  config,
  lib,
  ...
}:
let
  cfg = config.user.desktop.mimeapps;
in
{
  options.user.desktop.mimeapps.enable =
    lib.mkEnableOption "mimeapps.list (XDG default applications)";

  config = lib.mkIf cfg.enable {
    home.file = {
      # out-of-store: desktop apps rewrite the default-applications list.
      ".config/mimeapps.list".source =
        config.lib.file.mkOutOfStoreSymlink config.homeModulesPath
        + "/features/desktop/mimeapps/mimeapps.list";
    };
  };
}
