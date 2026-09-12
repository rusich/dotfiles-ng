{
  config,
  lib,
  ...
}:
let
  cfg = config.features.editors.omnisharp;
in
{
  options.features.editors.omnisharp.enable = lib.mkEnableOption "omnisharp (C# LSP config)";

  config = lib.mkIf cfg.enable {
    home.file.".omnisharp/omnisharp.json".source = ./omnisharp.json;
  };
}
