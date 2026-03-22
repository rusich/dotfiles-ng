{ pkgs, ... }:
{
  services.desktopManager.gnome.enable = true;

  environment.systemPackages = with pkgs; [
    whitesur-cursors
    gnome-tweaks
  ];
}
