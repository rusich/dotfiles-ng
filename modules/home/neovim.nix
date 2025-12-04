{
  config,
  pkgs,
  ...
}:
{

  home.packages = with pkgs; [
    tree-sitter # for latext TS
    ghostscript_headless
    texlive.combined.scheme-full
    mermaid-cli
    # python313Packages.pylatexenc # for render-markdown.nvim
    # (texlive.combine {
    #   inherit (texlive)
    #     scheme-full
    #     amsmath
    #     # amssymb
    #     amsfonts
    #     mathtools
    #     ;
    # })

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
