{
  config,
  pkgs,
  ...
}:
{
  # required packages
  home.packages = with pkgs; [
    xdg-desktop-portal-gtk
    xdg-desktop-portal-gnome
    xwayland-satellite
  ];

  # Map the niri config files to standard location
  home.file = {
    ".config/niri".source = config.lib.file.mkOutOfStoreSymlink config.homeModulesPath + "/niri/config";
  };

}
