{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.my.nixosModules.gnome;
in
{
  options = {
    my.nixosModules.gnome.enable = lib.mkEnableOption "GNOME Desktop Environment";
  };
  config = lib.mkIf cfg.enable {
    services.desktopManager.gnome.enable = true;

    environment.systemPackages = with pkgs; [
      whitesur-cursors
      gnome-tweaks
    ];
  };
}
