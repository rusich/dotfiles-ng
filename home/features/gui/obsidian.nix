{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.gui.obsidian;
in
{
  options.features.gui.obsidian.enable = lib.mkEnableOption "obsidian";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # obsidian
    ];
  };
}
