{config, ...}: {
  home.file = {
    ".editorconfig".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/modules/home/editorconfig/editorconfig";
  };
}
