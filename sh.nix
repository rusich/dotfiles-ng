{ config, pkgs, userSettings, ... }:
let
  myAliases = {
    ".." = "cd ..";
    "hms" = "home-manager switch --flake ~/.dotfiles/";
    "aaa" = userSettings.username;
    "nos" = "sudo nixos-rebuild switch --flake ~/.dotfiles/";
  };
in
{
  # Bash 
  programs.bash = {
    enable = true;
    shellAliases = myAliases;  
  };

  # Fish 
  programs.fish = {
    enable = true;
    shellAliases = myAliases;  
  };
}
