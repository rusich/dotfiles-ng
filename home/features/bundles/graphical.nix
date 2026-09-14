# Meta-feature: cross-platform GUI workstation bundle.
#
# This is an opinionated selection (editors, CLI, GUI apps, PIM, rust,
# opencode) meant for graphical machines. Servers must NOT enable it: it
# pulls GUI applications and out-of-store config symlinks.
{
  config,
  lib,
  ...
}:
let
  cfg = config.user.bundle.graphical;
in
{
  options.user.bundle.graphical.enable = lib.mkEnableOption "cross-platform GUI workstation bundle";

  config = lib.mkIf cfg.enable {
    user.editors = {
      neovim.enable = true;
      omnisharp.enable = true;
    };

    user.cli = {
      yazi = {
        enable = true;
        graphical = true;
      };
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
      portal.enable = true;
    };

    user.pim = {
      calendar.enable = true;
      contacts.enable = true;
    };

    user.dev = {
      rust.enable = true;
      toolbox.enable = true;
    };

    user.opencode.enable = true;
  };
}
