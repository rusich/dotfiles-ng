{config, ...}: {
  home.file = {
    ".editorconfig".source =
      config.lib.file.mkOutOfStoreSymlink config.homeModulesPath + "/editorconfig/editorconfig";
  };
}
