# UEFI-only GPT layout for the MacBook Air (Apple firmware; internal SSD absent,
# the system lives on a USB flash drive). No BIOS/EF02 partition is needed.
#   ESP (/boot) + swap (resume device) + ext4 root.
# Device is pinned by the Samsung flash's by-id: on this machine the target and
# a bootable SD installer are both USB mass storage (sda/sdb is a coin flip), so
# /dev/sda is NOT safe. Override per host or at install time if the flash changes.
{ lib, ... }:
{
  disko.devices = {
    disk.disk1 = {
      device = lib.mkDefault "/dev/disk/by-id/usb-Samsung_Flash_Drive_FIT_0374525090001858-0:0";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          esp = {
            name = "ESP";
            label = "ESP";
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "fmask=0077"
                "dmask=0077"
              ];
            };
          };
          swap = {
            name = "swap";
            label = "swap";
            size = "8G";
            content = {
              type = "swap";
              resumeDevice = true;
            };
          };
          root = {
            name = "root";
            label = "root";
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              # atime не обновляем (лишние записи на флешку), commit=60 — реже
              # журнальные синхронизации ext4. Совпадает с прежней ручной настройкой.
              mountOptions = [
                "noatime"
                "commit=60"
              ];
            };
          };
        };
      };
    };
  };
}
