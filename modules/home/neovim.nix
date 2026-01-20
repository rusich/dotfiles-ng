{
  config,
  pkgs,
  ...
}:
{

  home.packages = with pkgs; [
    tree-sitter # for latext TS
    # need for display math formulas via Snacks.nvim
    ghostscript_headless
    texlive.combined.scheme-full
    # for mermaid grapth support via Snacks.nvim
    mermaid-cli
  ];
  # backup nvim config
  home.file = {
    ".config/nvim_old".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/legacy-configs/nvim_old";
  };

  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/legacy-configs/nvim_old";

  programs.neovim = {
    # enable = true; # enabling this break nixvim
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };

}
