{
  config,
  lib,
  ...
}:
let
  cfg = config.user.editors.omnisharp;
in
{
  options.user.editors.omnisharp.enable = lib.mkEnableOption "omnisharp (C# LSP config)";

  config = lib.mkIf cfg.enable {
    home.file.".omnisharp/omnisharp.json".source = ./omnisharp.json;
  };
}
