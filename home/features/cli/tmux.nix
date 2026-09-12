{
  config,
  lib,
  ...
}:
let
  cfg = config.features.cli.tmux;
in
{
  options.features.cli.tmux.enable = lib.mkEnableOption "tmux";

  config = lib.mkIf cfg.enable {
    programs.tmux = {
      enable = true;
    };
  };
}
