{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.my.nixosModules.virt.client;
in
{
  options = {
    my.nixosModules.virt.client.enable = lib.mkEnableOption "virtualization clients";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      quickgui
      spice-gtk
      virt-viewer
    ];

    # Включает графический интерфейс Virt-Manager для управления ВМ
    # Устанавливает virt-manager (GUI) и virt-viewer (клиент для подключения)
    programs.virt-manager.enable = true;

  };
}
