{ ... }:
{
  imports = [
    ./common.nix
    ./nix.nix
  ];
}

# { inputs, ... }:
# {
#   imports =
#     with builtins;
#     map (fn: ./${fn}) (
#       filter (fn: fn != "default.nix" && fn != "disabled") (
#         attrNames (readDir "${inputs.self}/modules/nixos")
#       )
#     );
#
# }
