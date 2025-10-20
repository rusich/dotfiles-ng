{ config, pkgs, userSettings, ... }: {
  programs.git = {
    enable = true;
    userName = "Ruslan Sergin";
    userEmail = "ruslan.sergin@gmail.com";
    extraConfig = { init.defaultBranch = "main"; };
  };
}
