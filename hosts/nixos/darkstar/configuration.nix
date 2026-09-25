{
  pkgs,
  ...
}:
{

  imports = [
    ./hardware-configuration.nix
  ];

  # Using modules
  nixos.hardware.amdgpu.enable = true;
  nixos.profiles.desktop.enable = true;
  nixos.profiles.gaming.enable = true;
  nixos.profiles.daw.enable = true;
  nixos.profiles.gamedev.enable = true;
  nixos.virtualisation.hypervisor.enable = true;
  nixos.virtualisation.client.enable = true;
  nixos.profiles.gnome.enable = true;
  nixos.profiles.embedded.enable = true;
  nixos.services.wireshark.enable = true;
  nixos.services.podman.enable = true;
  nixos.services.ollama.enable = true;

  console = {
    font = "ter-v24b";
  };

  # Host-specific packages
  environment.systemPackages = with pkgs; [
    wlr-randr
    xrandr
    anydesk
    custom.freelib
    discord
  ];

  services.udev = {
    enable = true;
    extraRules = ''
      # Force gamepad id's in order for IL-2 and War Thunder to work correctly
      # Defender COBRA M5 USB Joystick
      SUBSYSTEM=="input", ATTRS{idVendor}=="11c0", ATTRS{idProduct}=="5603", SYMLINK+="input/js0", MODE="0666"
      # ThrustMaster, Inc. HOTAS Warthog Joystick
      SUBSYSTEM=="input", ATTRS{idVendor}=="044f", ATTRS{idProduct}=="0402", SYMLINK+="input/js1", MODE="0666"
      # ThrustMaster, Inc. HOTAS Warthog Throttle
      SUBSYSTEM=="input", ATTRS{idVendor}=="044f", ATTRS{idProduct}=="0404", SYMLINK+="input/js2", MODE="0666"

      # Gigabyte B550 AORUS ELITE V2: USB devices and the xHCI controllers fire
      # spurious GPE wakeups that make the system resume immediately after
      # suspend entry. Disable USB wakeup on every USB device and xHCI
      # controller (wake via the power button still works).
      ACTION=="add", SUBSYSTEM=="usb", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"
      ACTION=="add", SUBSYSTEM=="pci", DRIVER=="xhci_hcd", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"
    '';
  };

  # Gigabyte B550 AORUS ELITE V2: GPP0 (PCIe bridge 0000:00:01.1) is an enabled
  # S4 wake source that fires spuriously and makes the system wake up right
  # after entering suspend. Writing the device name to /proc/acpi/wakeup
  # toggles it, so only toggle when still enabled.
  # See [[Gigabyte AORUS b550 Elite v2 fix broken suspend on Linux]].
  systemd.services.disable-gpp0-wakeup = {
    description = "Disable GPP0 ACPI wakeup source to fix suspend (Gigabyte B550)";
    wantedBy = [ "multi-user.target" ];
    after = [ "sysinit.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      if grep -q '^GPP0.*enabled' /proc/acpi/wakeup; then
        echo GPP0 > /proc/acpi/wakeup
      fi
    '';
  };

  # Line6 POD HD500 (USB audio, driver snd_usb_podhd) oopses in line6_suspend()
  # when entering sleep (RIP: line6_suspend+0x1e/0x70 [snd_usb_line6]), which
  # wedges the whole machine on suspend entry. Deauthorize the device before
  # sleep and reauthorize it on resume so the buggy suspend callback never runs.
  powerManagement.powerDownCommands = ''
    for d in /sys/bus/usb/devices/*/; do
      if [ "$(cat "$d/idVendor" 2>/dev/null)" = "0e41" ] && [ "$(cat "$d/idProduct" 2>/dev/null)" = "414d" ]; then
        echo 0 > "$d/authorized"
      fi
    done
  '';
  powerManagement.resumeCommands = ''
    for d in /sys/bus/usb/devices/*/; do
      if [ "$(cat "$d/idVendor" 2>/dev/null)" = "0e41" ] && [ "$(cat "$d/idProduct" 2>/dev/null)" = "414d" ]; then
        echo 1 > "$d/authorized"
      fi
    done
  '';

  # XrayDisk 128GB (Silicon Motion SM2263EN, DRAM-less, Windows disk): after an
  # S3 resume the root port 0000:03:03.0 and the drive fail the D3hot->D0
  # transition ("device inaccessible") and the kernel disables the controller,
  # so the disk vanishes until a cold power cycle. Disable NVMe APST so the
  # drive does not park itself in a power state it cannot wake up from.
  boot.kernelParams = [ "nvme_core.default_ps_max_latency_us=0" ];

  # Wake-on-LAN for the onboard Realtek RTL8125 (eno1). The interface is managed
  # by NetworkManager, so arm WoL via a udev .link file (honored by udev whether
  # or not systemd-networkd runs, and not touched by NM's default wake-on-lan
  # setting). "magic" = classic magic-packet WoL. For waking from S5 the BIOS
  # option Settings -> Platform Power -> "Wake on LAN" must be Enabled and "ErP"
  # Disabled (ErP cuts standby power in S5).
  systemd.network.links."40-eno1" = {
    matchConfig.OriginalName = "eno1";
    linkConfig.WakeOnLan = "magic";
  };

  users.users.zaychik = {
    isNormalUser = true;
    description = "Sakhaya Sergina";
    extraGroups = [ "networkmanager" ];
  };

  users.users.busya = {
    isNormalUser = true;
    description = "Kristina Sergina";
    extraGroups = [ "networkmanager" ];
  };

  boot.supportedFilesystems = [
    "ntfs"
    "btrfs"
    "exfat"
    "zfs"
  ];

  networking.hostId = "69cfd900"; # for zfs support
  boot.zfs.forceImportRoot = false;

  fileSystems."/mnt/nvme500g/wt" = {
    device = "/dev/disk/by-uuid/2B52D7E135A3AB06";
    fsType = "ntfs";
    options = [
      "defaults"
      "nofail"
      "noatime"
      "users"
      "exec"
      "rw"
      "uid=1000"
      "gid=100"
      # "umask=000"
      # "nosuid"
      # "nodev"
      # "x-gfvs-show"
    ];
  };

  fileSystems."/mnt/nvme500g/dcs" = {
    device = "/dev/disk/by-uuid/C0E4-C1F9";
    fsType = "exfat";
    # device = "/dev/disk/by-uuid/8432d060-bbd1-48e2-b45a-a7c27239c39c";
    # fsType = "ext4";
    options = [
      "defaults"
      "nofail"
      "noatime"
      "users"
      "exec"
      "rw"
      "uid=1000"
      "gid=100"
    ];
  };

  fileSystems."/mnt/windows" = {
    device = "/dev/disk/by-uuid/01DC2D1572919960";
    fsType = "ntfs";
    options = [
      "defaults"
      "nofail"
      "noatime"
      "users"
      "exec"
      "rw"
      "uid=1000"
      "gid=100"
      # "umask=000"
      # "nosuid"
      # "nodev"
      # "x-gfvs-show"
    ];
  };

  # --- Homelab SMB (guest-шара public, rw) ---
  fileSystems."/mnt/homelab_public" = {
    device = "//192.168.5.2/public";
    fsType = "cifs";
    options = [
      # автомонтирование по обращению; nofail — не блокировать загрузку без сервера
      "x-systemd.automount,noauto,nofail"
      "x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s"
      # безопасность на медиа-шаре (noexec убрать, если нужен запуск скриптов)
      "nosuid,nodev"
      # "noexec" # расскомментировать, чтобы отключить запуск с шары
      # маппинг: uid 1000 (rusich) + группа 3000 (media); rw для владельца/группы
      "noperm,uid=1000,gid=100,file_mode=0660,dir_mode=2770"
      # SMB3.1.1 (сервер: min SMB2_02, max SMB3_11)
      "vers=3.1.1"
    ];
  };

  fileSystems."/mnt/keenetic_opkg" = {
    device = "//192.168.5.1/opkg";
    fsType = "cifs";
    options =
      let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
      in
      [ "${automount_opts},username=root,domain=WORKGROUP,uid=1000,gid=100" ];
  };

  networking.firewall.allowedTCPPorts = [
    10308 # DCS-world server
    4096 # opencode web
  ];

  networking.firewall.allowedUDPPorts = [
    10308 # DCS-world server
  ];

  # Move this to common config?
  system.stateVersion = "25.05";

  # # # DPI fixes on homelan via nfqws2-keenetic
  # boot.kernel.sysctl = {
  #   # "net.ipv4.tcp_timestamps" = 0;
  #   "net.ipv4.tcp_sack" = 0;
  #   # "net.ipv4.tcp_dsack" = 0;
  #   #   # if rebuild slow try this ->
  #   #   # "net.ipv4.tcp_fastopen" = 3;
  #   #   # "net.ipv4.tcp_mtu_probing" = 1;
  # };

  # Defaults is:
  # net.ipv4.tcp_sack = 1
  # net.ipv4.tcp_timestamps = 1
  # net.ipv4.tcp_fastopen = 1
  # net.ipv4.tcp_mtu_probing = 0
}
