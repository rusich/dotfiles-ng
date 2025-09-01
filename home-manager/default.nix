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
    ./aliases.nix
    ./base.nix
    ./dircolors.nix
    ./dotfiles.nix
    ./packages.nix
    ./path.nix
    ./stylix.nix
    ./vars.nix
    ./xdg.nix
    ./modules/bash.nix
    ./modules/bat.nix
    ./modules/delta.nix
    ./modules/firefox.nix
    ./modules/fish.nix
    ./modules/git.nix
    ./modules/starship.nix
    ./modules/zoxide.nix
    ./modules/zsh.nix
    # inputs.nix-colors.homeManagerModules.default
    # ./theming-example/alacritty.nix
  ];

  # for nixd
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };
}
