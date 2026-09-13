# Cross-platform features enabled on all of the user's GUI machines.
# Imported by desktop.nix and darwin.nix; servers do NOT import this.
{
  user.editors = {
    neovim.enable = true;
    omnisharp.enable = true;
  };

  user.cli = {
    yazi.enable = true;
    television.enable = true;
    tmux.enable = true;
    nix-search-tv.enable = true;
    translate_shell.enable = true;
  };

  user.gui = {
    firefox.enable = true;
    keepassxc.enable = true;
    obsidian.enable = true;
    onlyoffice.enable = true;
    packages.enable = true;
  };

  user.pim = {
    calendar.enable = true;
    contacts.enable = true;
  };

  user.dev.rust.enable = true;

  user.opencode.enable = true;
}
