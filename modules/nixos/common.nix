{
  pkgs,
  ...
}:
let
  vimAliases = {
    "v" = "nvim";
    "vim" = "nvim";
    "vi" = "nvim";
  };
in
{
  # NEOVIM
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    package = pkgs.unstable.neovim-unwrapped;
  };

  programs.bash.shellAliases = vimAliases;
  programs.fish.shellAliases = vimAliases;
  programs.zsh.shellAliases = vimAliases;

  # Nix store optimisation
  nix.optimise = {
    automatic = true;
    dates = [ "daily" ];
  };

  # Automatic upgrading
  system.autoUpgrade = {
    enable = false;
    allowReboot = false;
    # flake = "/path/to/flake";
    dates = "weekly";

  };

  # Fix hardware clock on dualboot
  time.hardwareClockInLocalTime = true;

}
