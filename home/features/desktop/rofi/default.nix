{ config, ... }: {
  home.file = {
    # out-of-store: noctalia writes generated themes into this dir.
    ".config/rofi".source =
      config.lib.file.mkOutOfStoreSymlink config.homeModulesPath + "/features/desktop/rofi/config";
  };
}
