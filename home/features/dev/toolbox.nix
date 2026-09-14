{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.user.dev.toolbox;
in
{
  options.user.dev.toolbox.enable =
    lib.mkEnableOption "dev toolbox (nodejs, luarocks, mdcat, cht-sh, gh)";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nodejs_24
      luarocks
      mdcat
      cht-sh
      gh
    ];
  };
}
