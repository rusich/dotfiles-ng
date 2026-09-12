{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.cli.yazi;
in
{
  options.features.cli.yazi.enable = lib.mkEnableOption "yazi file manager";

  config = lib.mkIf cfg.enable (import ./yazi-body.nix { inherit pkgs lib; });
}
