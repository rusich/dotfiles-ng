{
  config,
  pkgs,
  ...
}:
{

  home.packages = with pkgs; [
    tree-sitter # for latext TS
    python313Packages.pylatexenc # for render-markdown.nvim

  ];
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

}
