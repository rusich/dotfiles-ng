{ config, pkgs, userSettings, ... }:
let
  myAliases = {
    ".." = "cd ..";
    "hms" = "home-manager switch --flake ~/.dotfiles/nix/";
    "aaa" = userSettings.username;
    "nos" = "sudo nixos-rebuild switch --flake ~/.dotfiles/nix/";
    "home-manager" = "home-manager --flake ~/.dotfiles/nix/";
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
