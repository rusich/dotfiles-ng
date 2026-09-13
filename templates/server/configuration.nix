# Шаблон серверного хоста.
#
# Как использовать:
#   1. mkdir -p hosts/nixos/<server>
#   2. скопировать этот файл в hosts/nixos/<server>/configuration.nix
#   3. рядом положить hardware-configuration.nix (nixos-generate-config на сервере
#      или nixos-anywhere --generate-hardware-config, когда добавим disko)
#   4. создать home/users/rusich/<server>.nix:
#        { ... }: { imports = [ ./home.nix ]; }   # база, без user.bundle.*
#      (user.bundle.* добавляют GUI/out-of-store фичи — серверу не нужны)
#   5. с десктопа:
#        nixos-rebuild switch --flake .#<server> --target-host root@<server>
#
# Общее для всех NixOS-хостов (SSH, fish, primary user с ключами, временная зона,
# локали, nix settings) уже приходит из modules/nixos/{common,users,nix}.nix —
# здесь только машинная специфика.
{
  lib,
  hostname,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = hostname;
    useDHCP = lib.mkDefault true;
    # networkd + статический адрес (пример):
    # useNetworkd = true;
    # systemd.network.networks."10-enp1s0" = {
    #   matchConfig.Name = "enp1s0";
    #   address = [ "192.168.5.10/24" ];
    #   networkConfig.DHCP = "no";
    # };
  };

  # Деплой home-manager вместе с системой (nixos-rebuild), а не standalone.
  nixos.home-manager.integrated.enable = true;

  # Зафиксировать версию при установке и не менять впоследствии.
  system.stateVersion = "26.05";
}
