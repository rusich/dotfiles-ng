{
  config,
  ...
}:
{

  programs.zk.enable = true;

  # backup nvim config
  home.file = {
    ".config/zk/config.toml".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/modules/home/zk/config.toml";
  };
}
