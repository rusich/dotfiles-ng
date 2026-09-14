# Шаблон серверного хоста (disko + nixos-anywhere + integrated home-manager).
#
# Как использовать:
#   1. mkdir -p hosts/nixos/<server>
#   2. скопировать сюда configuration.nix и disko.nix
#   3. hardware-configuration.nix создаст `just deploy` при первой установке
#      (nixos-anywhere --generate-hardware-config)
#   4. создать home/users/rusich/<server>.nix:
#        { ... }: { imports = [ ./home.nix ]; }   # база, без user.bundle.*
#      (user.bundle.* добавляют GUI/out-of-store фичи — серверу не нужны)
#   5. с десктопа:
#        just deploy <server> <host-or-ip>    # установка с нуля (СТИРАЕТ диск)
#        just rebuild <server> <host-or-ip>   # последующие обновления
#
# Общее для всех NixOS-хостов (SSH, fish, primary user с ключами, временная зона,
# локали, nix settings) уже приходит из modules/nixos/{common,users,nix}.nix —
# здесь только машинная специфика.
{
  modulesPath,
  lib,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./hardware-configuration.nix
    ./disko.nix
  ];

  # disko создаёт BIOS-boot (EF02) + ESP; grub ставится в ESP без записи в NVRAM.
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking = {
    useDHCP = lib.mkDefault true;
    # networkd + статический адрес (пример):
    # useNetworkd = true;
    # systemd.network.networks."10-enp1s0" = {
    #   matchConfig.Name = "enp1s0";
    #   address = [ "192.168.5.10/24" ];
    #   networkConfig.DHCP = "no";
    # };
  };

  # Headless-профиль: daily gc/optimise, resolved, key-only SSH, серверные пакеты.
  nixos.profiles.server.enable = true;

  # Деплой home-manager вместе с системой (nixos-rebuild), а не standalone.
  nixos.home-manager.integrated.enable = true;

  # Зафиксировать версию при установке и не менять впоследствии.
  system.stateVersion = "26.05";
}
