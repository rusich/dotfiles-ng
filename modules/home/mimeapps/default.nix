{config, ...}: {
  home.file = {
    # common
    ".config/mimeapps.list".source =
      config.lib.file.mkOutOfStoreSymlink config.homeModulesPath + "/mimeapps/mimeapps.list";
  };
}
