{ config, ... }: {
  home.file = {
    ".omnisharp/omnisharp.json".source =
      config.lib.file.mkOutOfStoreSymlink config.homeModulesPath
      + "/features/editors/omnisharp/omnisharp.json";
  };
}
