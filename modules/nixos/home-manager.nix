{
  config,
  lib,
  inputs,
  primaryUser,
  hostname,
  ...
}:
let
  cfg = config.nixos.home-manager.integrated;
in
{
  options.nixos.home-manager.integrated = {
    enable = lib.mkEnableOption "integrated home-manager, deployed via nixos-rebuild (servers)";
    user = lib.mkOption {
      type = lib.types.str;
      default = primaryUser.username;
      description = "User whose home/users/<user>/<host>.nix is deployed";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {
        inherit inputs hostname;
        primaryUser = primaryUser;
      };
      users.${cfg.user} = import (inputs.self + "/home/users/${cfg.user}/${hostname}.nix");
    };
  };
}
