{ config, pkgs, userSettings, ... }: {
  programs.dircolors = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    settings = {

    };
  };
}
