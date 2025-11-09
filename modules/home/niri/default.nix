{
  config,
  pkgs,
  homeModules,
  ...
}:
{

  # Map the niri config files to standard location
  home.file = {
    # this is readonly
    # ".config/niri".source = config.lib.file.mkOutOfStoreSymlink "${homeModules}/niri/config";

    # and this is editable
    ".config/niri".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/modules/home/niri/config";
  };

}
