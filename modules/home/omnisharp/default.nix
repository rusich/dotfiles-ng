{config, ...}: {
  home.file = {
    ".omnisharp/omnisharp.json".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/modules/home/omnisharp/omnisharp.json";
  };
}
