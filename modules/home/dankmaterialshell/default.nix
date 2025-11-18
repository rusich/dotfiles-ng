{
  inputs,
  pkgs,
  config,
  system,
  ...
}:
{
  imports = [
    inputs.dankMaterialShell.homeModules.dankMaterialShell.default
    # inputs.dankMaterialShell.homeModules.dankMaterialShell.niri
  ];

  home.packages = with pkgs; [
    # unstable.kdePackages.qtmultimedia
    kdePackages.qtmultimedia
    adw-gtk3
  ];

  programs.dankMaterialShell = {
    enable = true;
    quickshell.package = inputs.quickshell.packages."${system}".default;
    # quickshell.package = pkgs.unstable.quickshell;
    # niri = {
    #   enableKeybinds = true; # Automatic keybinding configuration
    #   enableSpawn = true; # Auto-start DMS with niri
    # };
    enableSystemSound = true; # System sound effects
  };

  # Map the niri config files to standard location
  home.file = {
    # this is readonly
    # ".config/niri".source = config.lib.file.mkOutOfStoreSymlink "${homeModules}/niri/config";

    #and this is editable
    ".config/DankMaterialShell".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/modules/home/dankmaterialshell/config";
  };

}
