{
  userSettings,
  inputs,
  outputs,
  homeModules,
  userConfig,
  pkgs,
  lib,
  ...
}:
{

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  ########

  # cleanup system automatically
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = "daily";
    options = lib.mkDefault "--delete-older-than 7d";
  };

  ###########

  nixpkgs = {
    config = {
      allowUnfreePredicate = (_: true);
    };
  };

  home = rec {

    stateVersion = "25.05";
    username = userConfig.username;
    homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
    # homeDirectory = "/Users/rusich";

    packages = with pkgs; [
      fastfetch
      neofetch
    ];
  };

  # Enable alacritty
  programs.alacritty.enable = true;

  # # SwayOSD
  # services.swayosd.enable = true;

  # Remmina
  services.remmina.enable = true;

  # for nixd
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  # This will, for example, allow fontconfig to discover fonts and configurations installed through home.packages
  fonts.fontconfig.enable = true;

  # automatically import all home-manager modules
  # services.polkit-gnome.enable = true; # use from dms instead

  imports =
    with builtins;
    map (fn: ./${fn}) (
      filter (fn: fn != "default.nix" && fn != "disabled") (attrNames (readDir "${homeModules}"))
    );

}
