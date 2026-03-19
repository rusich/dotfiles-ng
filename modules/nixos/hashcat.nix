{ pkgs, ... }:
{
  # В конфигурации NixOS (/etc/nixos/configuration.nix)
  environment.systemPackages = with pkgs; [
    # (hashcat.override { enableAMD = true; })
    hashcat
    hashcat-utils
    rocmPackages.rocminfo
    john
  ];

  # ROCM для AMD GPU
  hardware.graphics.extraPackages = with pkgs; [
    rocmPackages.clr.icd
    # amdvlk
  ];

  systemd.tmpfiles.rules = [
    "L+ /opt/rocm - - - - ${pkgs.rocmPackages.clr}"
  ];
  # Убедитесь, что пользователь в группе video/render
  users.users.rusich.extraGroups = [
    "video"
    "render"
  ];

}
