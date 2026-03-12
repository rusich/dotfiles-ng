{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    tree-sitter # for latext TS
    # need for display math formulas via Snacks.nvim
    ghostscript_headless
    texlive.combined.scheme-full
    # for mermaid grapth support via Snacks.nvim
    mermaid-cli
    sqlite # for vim-dadbod
  ];

  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink config.homeModulesPath + "/neovim/config";
}
