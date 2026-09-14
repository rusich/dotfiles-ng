{
  primaryUser,
  pkgs,
  lib,
  config,
  ...
}:
let
  entries = builtins.readDir ./.;
  isModule = name: type: name != "default.nix" && (type == "directory" || lib.hasSuffix ".nix" name);
in
{
  imports = [
    ../features
  ]
  ++ lib.mapAttrsToList (name: _: ./. + "/${name}") (lib.filterAttrs isModule entries);

  options = {
    homePath = lib.mkOption {
      type = lib.types.str;
      default =
        if pkgs.stdenv.isDarwin then "/Users/${primaryUser.username}" else "/home/${primaryUser.username}";
      description = "Path to home directory";
    };
    dotfilesPath = lib.mkOption {
      type = lib.types.str;
      default = config.homePath + "/.dotfiles";
      description = "Path to dotfiles directory";
    };
    homeModulesPath = lib.mkOption {
      type = lib.types.str;
      default = config.dotfilesPath + "/home";
      description = "Path to home modules directory";
    };
  };

  config = {
    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    # yazi is part of the base set for every machine (TUI, works headless);
    # desktop-only bits (portal/desktop-entry/noctalia/gvfs) are opt-in via
    # user.cli.yazi.graphical, enabled by the graphical bundle.
    user.cli.yazi.enable = true;

    home = {
      stateVersion = "25.05";
      username = primaryUser.username;
      homeDirectory = config.homePath;
    };

    # This will, for example, allow fontconfig to discover fonts and configurations installed through home.packages
    fonts.fontconfig.enable = true;
  };
}
