{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.desktop.udiskie;
in
{
  options.features.desktop.udiskie.enable = lib.mkEnableOption "udiskie automount tray";

  config = lib.mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    services.udiskie = {
      enable = true;
      settings = {
        program_options = {
          # replace with your favorite file manager
          file_manager = "${pkgs.nautilus}/bin/nautilus";
        };
      };
    };
  };
}
