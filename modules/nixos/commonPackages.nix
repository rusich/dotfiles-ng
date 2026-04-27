{ pkgs, config, ... }:
{
  environment.systemPackages =
    with pkgs;
    [
      cowsay
      traceroute
      lm_sensors
      cifs-utils
    ]
    ++ config.commonSystemPackages;
}
