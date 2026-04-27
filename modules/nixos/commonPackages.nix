{ pkgs, config, ... }:
{
  environment.systemPackages =
    with pkgs;
    [
      cowsay
    ]
    ++ config.commonSystemPackages;
}
