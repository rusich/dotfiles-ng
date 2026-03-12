{config, ...}: {
  home.file = {
    ".config/rofi".source =
      config.lib.file.mkOutOfStoreSymlink config.homeModulesPath + "/rofi/config";
  };
}
