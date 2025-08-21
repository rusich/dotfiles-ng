{ config, ... }:

{
  home.file = {
    ".config/mimeapps.list".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.dotfiles/home-manager/dotfiles/mimeapps.list";
    ".editorconfig".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.dotfiles/home-manager/dotfiles/home/editorconfig";
  };
}