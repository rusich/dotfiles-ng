{ inputs, pkgs, ... }:
{
  imports = [
    inputs.dankMaterialShell.homeModules.dankMaterialShell.default
    # inputs.dankMaterialShell.homeModules.dankMaterialShell.niri
  ];

  programs.dankMaterialShell = {
    enable = true;
    quickshell.package = pkgs.unstable.quickshell;
    # niri = {
    #   enableKeybinds = true; # Automatic keybinding configuration
    #   enableSpawn = true; # Auto-start DMS with niri
    # };
  };

}
