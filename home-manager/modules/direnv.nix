{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableBashIntegration = true;
    silent = false;
  };
}
