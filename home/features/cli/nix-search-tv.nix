{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.user.cli.nix-search-tv;
  ns = pkgs.writeShellScriptBin "ns" (builtins.readFile "${pkgs.nix-search-tv.src}/nixpkgs.sh");
in
{
  options.user.cli.nix-search-tv.enable = lib.mkEnableOption "nix-search-tv";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      ns
      fzf
    ];

    programs.nix-search-tv = {
      enable = true;
    };
  };
}
