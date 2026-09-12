{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.cli.television;
in
{
  options.features.cli.television.enable = lib.mkEnableOption "television fuzzy finder";

  config = lib.mkIf cfg.enable {
    xdg.configFile."television".source = ./config;

    home.packages = with pkgs; [
      tldr
    ];
    services.tldr-update.enable = true;

    programs.television = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

    programs.nix-search-tv = {
      enableTelevisionIntegration = false;
    };
  };
}
