{ pkgs, ... }:
let
  vimAliases = {
    "v" = "nvim";
    "vim" = "nvim";
    "vi" = "nvim";
  };
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    package = pkgs.unstable.neovim-unwrapped;
  };

  programs.bash.shellAliases = vimAliases;
  programs.fish.shellAliases = vimAliases;
  programs.zsh.shellAliases = vimAliases;

}
