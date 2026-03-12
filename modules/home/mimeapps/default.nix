{config, ...}: {
  home.file = {
    # common
    ".config/mimeapps.list".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/modules/home/mimeapps/mimeapps.list";
  };
}
