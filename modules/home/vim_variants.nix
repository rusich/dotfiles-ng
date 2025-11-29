{
  config,
  ...
}:
{

  # backup nvim config
  home.file = {
    ".config/obsvim".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/legacy-configs/obsvim";

    ".config/televim".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/legacy-configs/televim";

  };

  programs.fish.shellAliases = {
    "obsvim" = "NVIM_APPNAME=obsvim nvim";
    "televim" = "NVIM_APPNAME=televim nvim";
  };
}
