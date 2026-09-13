# Auto-load every meta-feature bundle in this directory.
{ lib, ... }:
let
  entries = builtins.readDir ./.;
  isModule = name: type: name != "default.nix" && (type == "directory" || lib.hasSuffix ".nix" name);
in
{
  imports = lib.mapAttrsToList (name: _: ./. + "/${name}") (lib.filterAttrs isModule entries);
}
