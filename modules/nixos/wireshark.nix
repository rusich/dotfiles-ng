{
  config,
  lib,
  primaryUser,
  pkgs,
  ...
}:
let
  cfg = config.nixos.services.wireshark;
in
{
  options = {
    nixos.services.wireshark.enable = lib.mkEnableOption "Wireshark and add users to wireshark group";
  };
  config = lib.mkIf cfg.enable {
    programs.wireshark.enable = true;

    environment.systemPackages = with pkgs; [
      wireshark
    ];

    users.users.${primaryUser.username} = {
      isNormalUser = true;
      extraGroups = [
        "wireshark"
      ];
    };
  };
}
