{
  config,
  pkgs,
  userSettings,
  inputs,
  system,
  ...
}:
{
  imports = [
    ./shell.nix
    ./git.nix
    ./pkgs.nix
    ./file.nix
    ./vars.nix
    ./path.nix
    ./dircolors.nix
    ./modules/base.nix
    ./modules/xdg.nix
    ./modules/stylix.nix
    ./modules/firefox.nix
    # inputs.nix-colors.homeManagerModules.default
    # ./theming-example/alacritty.nix
  ];
}
