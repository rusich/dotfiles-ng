{ config, pkgs, userSettings, ... }:
let
  myAliases = {
    "home-manager" = "home-manager --flake ~/.dotfiles/";
    "ns" = "sudo nixos-rebuild switch --flake ~/.dotfiles/";
    "hs" = "home-manager switch --flake ~/.dotfiles/";
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
