{ pkgs, lib, ... }:
with lib;
{
  options = {
    my-service = {
      enable = mkEnableOption "My custom service";

      port = mkOption {
        type = types.port;
        default = 8080;
        description = "Port for my service";
      };
    };
  };
  config = {
    services.desktopManager.gnome.enable = true;

    environment.systemPackages = with pkgs; [
      whitesur-cursors
      gnome-tweaks
    ];
  };
}
