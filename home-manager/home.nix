{
  config,
  pkgs,
  userSettings,
  inputs,
  system,
  nixpkgs,
  ...
}:
{
  imports = [
    ./git.nix
    ./packages.nix
    ./vars.nix
    ./path.nix
    ./dircolors.nix
    ./modules/files/default.nix
    ./modules/base.nix
    ./modules/xdg.nix
    ./modules/stylix.nix
    ./modules/firefox.nix
    ./modules/aliases.nix
    ./modules/git-delta.nix
    ./modules/bat.nix
    ./modules/zoxide.nix
    ./modules/starship.nix
    ./modules/bash.nix
    ./modules/fish.nix
    ./modules/zsh.nix
    # inputs.nix-colors.homeManagerModules.default
    # ./theming-example/alacritty.nix
  ];

  # for nixd
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
}
