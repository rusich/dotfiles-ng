{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.user.gui.obsidian;
in
{
  options.user.gui.obsidian.enable = lib.mkEnableOption "obsidian";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # obsidian
    ];
  };
}
