{
  config,
  pkgs,
  homeModules,
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
    # this is readonly
    # ".config/niri".source = config.lib.file.mkOutOfStoreSymlink "${homeModules}/niri/config";

    # and this is editable
    ".config/niri".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/modules/home/niri/config";
  };

}
