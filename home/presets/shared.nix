# Cross-platform features enabled on all of the user's GUI machines.
# Imported by desktop.nix and darwin.nix; servers do NOT import this.
{
  features.editors = {
    neovim.enable = true;
    omnisharp.enable = true;
  };

  features.cli = {
    yazi.enable = true;
    television.enable = true;
    tmux.enable = true;
    nix-search-tv.enable = true;
    translate_shell.enable = true;
  };

  features.gui = {
    firefox.enable = true;
    keepassxc.enable = true;
    obsidian.enable = true;
    onlyoffice.enable = true;
  };
}
