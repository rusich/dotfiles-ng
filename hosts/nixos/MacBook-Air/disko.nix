# UEFI-only GPT layout for the MacBook Air (Apple firmware; internal SSD absent,
# the system lives on a USB flash drive). No BIOS/EF02 partition is needed.
#   ESP (/boot) + swap (resume device) + ext4 root.
# Override the device per host or at install time, e.g.:
#   nixos-anywhere ... --disk /dev/sda
{ lib, ... }:
{
  disko.devices = {
    disk.disk1 = {
      device = lib.mkDefault "/dev/sda";
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
