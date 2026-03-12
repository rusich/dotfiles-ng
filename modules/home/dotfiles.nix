{config, ...}: {
  home.file = {
    # common
    ".config/mimeapps.list".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/legacy-configs/mimeapps.list";
    # apps
    ".config/waybar".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/legacy-configs/waybar";
    ".config/rofi".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/legacy-configs/rofi";
    ".config/wlogout".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/legacy-configs/wlogout";
  };
}
