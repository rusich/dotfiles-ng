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
    # Move conflicting pre-existing files aside instead of aborting activation.
    # Hosts that previously managed some dotfiles by hand (e.g. MacBook-Air)
    # otherwise fail with "Existing file ... would be clobbered".
    home-manager.backupFileExtension = "hm-backup";

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      # Expose the sops-nix HM options to integrated users too (inert unless
      # user.secrets.enable / sops.* is set). Mirrors the standalone mkHome.
      sharedModules = [
        inputs.sops-nix.homeManagerModules.sops
      ];
      extraSpecialArgs = {
        inherit inputs hostname;
        primaryUser = primaryUser;
      };
      users.${cfg.user} = import (inputs.self + "/home/users/${cfg.user}/${hostname}.nix");
    };
  };
}
