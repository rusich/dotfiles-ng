{ config, pkgs, ... }:
{

  xdg.configFile."television".source =
    config.lib.file.mkOutOfStoreSymlink config.homeModulesPath + "/television/config";

  home.packages = with pkgs; [
    tldr
  ];
  services.tldr-update.enable = true;

  programs.television = {
    package = pkgs.unstable.television;
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.nix-search-tv = {
    enableTelevisionIntegration = false;
  };
}
