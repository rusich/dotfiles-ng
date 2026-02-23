{
  config,
  pkgs,
  lib,
  ...
}:

let
  myAliases = {
    # Standard
    "home-manager" = "home-manager --flake ~/.dotfiles/";
    "os" = "nh os switch";
    "hs" = "nh home switch";
    "s" = "os && hs";

    # ls and tree replacement with eza
    "ls" = "eza --icons --group-directories-first";
    "tree" = "eza --tree --icons --group-directories-first";

    # Nix packages online
    # "lumen" = "nix run github:jnsahaj/lumen -- ";
  };
in
{
  programs.bash.shellAliases = myAliases;
  programs.fish.shellAliases = myAliases;
  programs.zsh.shellAliases = myAliases;
}
