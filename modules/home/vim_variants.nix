{
  config,
  ...
}:
{

  # backup nvim config
  home.file = {
    ".config/obsvim".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/legacy-configs/obsvim";

    ".config/zkvim".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/legacy-configs/zkvim";

    ".config/neorgvim".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/legacy-configs/neorgvim";

  };

  programs.fish.shellAliases = {
    "obsvim" = "NVIM_APPNAME=obsvim nvim";
    "zkvim" = "NVIM_APPNAME=zkvim nvim";
    "neorgvim" = "NVIM_APPNAME=neorgvim nvim";
  };

}
