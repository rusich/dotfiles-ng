{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    quickemu
    quickgui
    spice
    spice-gtk
    virt-viewer
  ];

  # ============================================
  # ОПЦИИ ГИПЕРВИЗОРА (хостовой системы)
  # Используются, когда NixOS работает как ХОСТ для виртуальных машин
  # ============================================

  # Включает демон libvirtd для управления виртуальными машинами через KVM/QEMU
  # Демон libvirtd управляет жизненным циклом ВМ, сетями, хранилищами
  virtualisation.libvirtd.enable = true;

  # Включает перенаправление USB-устройств через SPICE протокол
  # Позволяет подключать USB-устройства с хоста к гостевой системе
  # Примеры: флешки, принтеры, веб-камеры, USB-ключи
  virtualisation.spiceUSBRedirection.enable = true;

  # Настраивает vhost-user протокол для QEMU, добавляет virtiofsd
  # Включает поддержку virtio-fs - высокопроизводительной файловой системы
  # для обмена файлами между хостом и гостевой системой
  virtualisation.libvirtd.qemu.vhostUserPackages = with pkgs; [ virtiofsd ];

  # Включает графический интерфейс Virt-Manager для управления ВМ
  # Устанавливает virt-manager (GUI) и virt-viewer (клиент для подключения)
  programs.virt-manager.enable = true;

  # ============================================
  # ДОПОЛНИТЕЛЬНЫЕ НАСТРОЙКИ ДЛЯ ГИПЕРВИЗОРА
  # ============================================

  # Модули ядра для аппаратной виртуализации
  # Выберите соответствующий модуль для вашего процессора
  boot.kernelModules = [
    "kvm-intel" # Для процессоров Intel с поддержкой VT-x
    "kvm-amd" # Для процессоров AMD с поддержкой AMD-V (раскомментировать при необходимости)
  ];

  boot.extraModprobeConfig = ''
    options kvm_intel nested=1
    options kvm_intel emulate_invalid_guest_state=0
    options kvm ignore_msrs=1
  '';

}
