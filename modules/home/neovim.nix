{
  config,
  ...
}:
{

  # backup nvim config
  home.file = {
    ".config/nvim_old".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/legacy-configs/nvim_old";

    ".config/nvim".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/legacy-configs/nvim_old";
  };

  programs.neovim = {
    # enable = true; # enabling this break nixvim
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };

  programs.nixvim = {
    enable = false;
    #   # config = {
    #   #   options = {
    #   #     number = true;
    #   #     relativenumber = true;
    #   #
    #   #     shiftwidth = 2;
    #   #   };
    #   # };
    #
    #   colorschemes.catppuccin.enable = true;
    #   plugins.lualine.enable = true;
  };

}
