# Auto-load all modules in the modules/nixos directory
{ inputs, ... }:
{
  imports =
    with builtins;
    map (fn: ./${fn}) (
      filter (fn: fn != "default.nix") (attrNames (readDir "${inputs.self}/modules/nixos"))
    );

}
