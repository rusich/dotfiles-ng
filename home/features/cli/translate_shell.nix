{
  config,
  lib,
  ...
}:
let
  cfg = config.features.cli.translate_shell;
in
{
  options.features.cli.translate_shell.enable = lib.mkEnableOption "translate-shell";

  config = lib.mkIf cfg.enable {
    programs.translate-shell = {
      enable = true;
      settings = {
        hl = "en";
        tl = [
          "ru"
        ];
        verbose = false;
      };
    };
  };
}
