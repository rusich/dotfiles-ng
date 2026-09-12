{
  primaryUser,
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./nix.nix
    ./xdg.nix
    ./vars.nix
    ./path.nix
    ./shell.nix
    ./packages.nix
    ./fish.nix
    ./starship.nix
    ./direnv.nix
    ./dircolors.nix
    ./git.nix
    ./delta.nix
    ./bat.nix
    ./aliases.nix
    ./zoxide.nix
    ./editorconfig.nix
    ../features
  ];

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

    home = {
      stateVersion = "25.05";
      username = primaryUser.username;
      homeDirectory = config.homePath;
    };

    # Enable alacritty
    programs.alacritty.enable = true;

    # Remmina
    services.remmina.enable = true;

    # This will, for example, allow fontconfig to discover fonts and configurations installed through home.packages
    fonts.fontconfig.enable = true;
  };
}
