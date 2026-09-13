{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.user.cli.television;
in
{
  options.user.cli.television.enable = lib.mkEnableOption "television fuzzy finder";

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
