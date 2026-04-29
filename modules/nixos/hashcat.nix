{
  pkgs,
  config,
  lib,
  userConfig,
  ...
}:
let
  cfg = config.my.nixosModules.hashcat;
in
{
  options = {
    my.nixosModules.hashcat.enable = lib.mkEnableOption "packages and settings related to Hashcat";
  };
  config = lib.mkIf cfg.enable {
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
    users.users.${userConfig.username}.extraGroups = [
      "video"
      "render"
    ];

  };
}
