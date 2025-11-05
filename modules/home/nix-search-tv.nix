{pkgs, ...}: let
  ns = pkgs.writeShellScriptBin "ns" (builtins.readFile "${pkgs.nix-search-tv.src}/nixpkgs.sh");
in {
  home.packages = with pkgs; [
    nix-search-tv
    ns
    fzf
  ];
}
