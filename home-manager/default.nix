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
    ./dircolors.nix
    ./dotfiles.nix
    ./packages.nix
    ./path.nix
    ./stylix.nix
    ./vars.nix
    ./xdg.nix
    ./bash.nix
    ./bat.nix
    ./delta.nix
    ./firefox.nix
    ./fish.nix
    ./git.nix
    ./starship.nix
    ./zoxide.nix
    ./zsh.nix
    ./direnv.nix
    ./hyprland
    # inputs.nix-colors.homeManagerModules.default
    # ./theming-example/alacritty.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = userSettings.username;
  home.homeDirectory = "/home/" + userSettings.username;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Enable alacritty
  programs.alacritty.enable = true;

  # SwayOSD
  services.swayosd.enable = true;

  # Remmina
  services.remmina.enable = true;

  # for nixd
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };
}
