{
  nixosModules,
  ...
}:
{
  imports =
    with builtins;
    map (fn: ./${fn}) (
      filter (fn: fn != "default.nix" && fn != "disabled") (attrNames (readDir "${nixosModules}/common"))
    );
}
