{
  config,
  lib,
  ...
}:
let
  cfg = config.user.cli.tmux;
in
{
  options.user.cli.tmux.enable = lib.mkEnableOption "tmux";

  config = lib.mkIf cfg.enable {
    programs.tmux = {
      enable = true;
    };
  };
}
