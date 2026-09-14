{
  imports = [ ./home.nix ];

  # Store-based features only: nothing depends on a local dotfiles checkout,
  # so busya does not need access to rusich's repository.
  user.cli = {
    yazi.enable = true;
    television.enable = true;
    tmux.enable = true;
    nix-search-tv.enable = true;
    translate_shell.enable = true;
  };

  user.gui = {
    firefox.enable = true;
    packages.enable = true;
    userDirs.enable = true;
    # Portal comes from the system GNOME module on darkstar, no HM override.
  };

  # NOTE: features that map configs via mkOutOfStoreSymlink (neovim, kitty,
  # niri, rofi, keepassxc, noctalia, opencode) require a local dotfiles
  # checkout. To enable them, busya should clone the repo to ~/.dotfiles and
  # enable user.bundle.graphical (or the individual features).
}
