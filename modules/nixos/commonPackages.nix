{ pkgs, config, ... }:
{
  environment.systemPackages =
    with pkgs;
    [
      # Ваши дополнительные пакеты
      cowsay
    ]
    ++ config.commonSystemPackages;
}
