{
  inputs,
  userConfig,
  pkgs,
  lib,
  config,
  ...
}:
{
  imports =
    with builtins;
    map (fn: ./${fn}) (
      # filter (fn: fn != "default.nix" && fn != "disabled") (attrNames (readDir "${homeModules}"))
      # filter (fn: fn != "default.nix" && fn != "disabled") (attrNames (readDir "${inputs.self}/modules/home"))
      filter (fn: fn != "default.nix" && fn != "disabled") (
        attrNames (readDir "${inputs.self}/modules/home")
      )
    );

  options = {
    homePath = lib.mkOption {
      type = lib.types.str;
      default = if pkgs.stdenv.isDarwin then "/Users/" else "/home/" + toString "${userConfig.username}";
      description = "Path to home directory";
    };
    dotfilesPath = lib.mkOption {
      type = lib.types.str;
      default = config.homePath + "/.dotfiles";
      description = "Path to dotfiles directory";
    };
    homeModulesPath = lib.mkOption {
      type = lib.types.str;
      default = config.dotfilesPath + "/modules/home";
      description = "Path to home modules directory";
    };
  };

  config = {
    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    ########

    ###########

    # nixpkgs = {
    #   config = {
    #     allowUnfreePredicate = _: true;
    #   };
    # };

    home = {
      stateVersion = "25.05";
      username = userConfig.username;
      homeDirectory = config.homePath;
      # if pkgs.stdenv.isDarwin
      # then "/Users/${username}"
      # else "/home/${username}";

      packages = with pkgs; [
        fastfetch
        neofetch
        neo
      ];
    };

    # Enable alacritty
    programs.alacritty.enable = true;

    # Remmina
    services.remmina.enable = true;

    # This will, for example, allow fontconfig to discover fonts and configurations installed through home.packages
    fonts.fontconfig.enable = true;
  };
}
