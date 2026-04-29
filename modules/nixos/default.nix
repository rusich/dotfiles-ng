# Auto-load all modules in the modules/nixos directory
{ inputs, ... }:
{
  imports =
    with builtins;
    map (fn: ./${fn}) (
      filter (fn: fn != "default.nix" && fn != "optional") (
        attrNames (readDir "${inputs.self}/modules/nixos")
      )
    );

}
