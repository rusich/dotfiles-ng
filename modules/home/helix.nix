{
  config,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
  ];

  # xdg.configFile."nvim".source =
  #   config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/legacy-configs/nvim_old";

  # All available options https://home-manager-options.extranix.com/?query=helix
  programs.helix = {
    enable = true;
  };

}
