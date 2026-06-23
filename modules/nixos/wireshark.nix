{
  config,
  lib,
  userConfig,
  pkgs,
  ...
}:
let
  cfg = config.my.nixosModules.wireshark;
in
{
  options = {
    my.nixosModules.wireshark.enable = lib.mkEnableOption "Wireshark and add users to wireshark group";
  };
  config = lib.mkIf cfg.enable {
    programs.wireshark.enable = true;

    environment.systemPackages = with pkgs; [
      wireshark
    ];

    users.users.${userConfig.username} = {
      isNormalUser = true;
      extraGroups = [
        "wireshark"
      ];
    };
  };
}
