{ config, ... }:

{
  home.file = {
    ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.dotfiles/home-manager/dotfiles/nvim";
    ".config/hypr".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.dotfiles/home-manager/dotfiles/hypr";
    ".config/keepassxc".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.dotfiles/home-manager/dotfiles/keepassxc";
    ".config/kitty".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.dotfiles/home-manager/dotfiles/kitty";
    ".config/waybar".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.dotfiles/home-manager/dotfiles/waybar";
    ".config/rofi".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.dotfiles/home-manager/dotfiles/rofi";
    ".config/wlogout".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.dotfiles/home-manager/dotfiles/wlogout";
  };
}