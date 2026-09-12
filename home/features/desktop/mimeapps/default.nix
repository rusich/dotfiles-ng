{ config, pkgs, ... }: {

  home.file = {
    # common
    # out-of-store: desktop apps rewrite the default-applications list.
    ".config/mimeapps.list".source =
      config.lib.file.mkOutOfStoreSymlink config.homeModulesPath
      + "/features/desktop/mimeapps/mimeapps.list";
  };
}
