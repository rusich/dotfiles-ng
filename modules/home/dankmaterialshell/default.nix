{
  inputs,
  pkgs,
  config,
  system,
  ...
}:
let
  colors = config.lib.stylix.colors;
in
{
  imports = [
    inputs.dms.homeModules.dankMaterialShell.default
  ];

  home.packages = with pkgs; [
    kdePackages.qtmultimedia
    adw-gtk3
  ];

  programs.dankMaterialShell = {
    enable = true;
    enableSystemMonitoring = true; # System monitoring widgets (dgop)
    enableClipboard = true; # Clipboard history manager
    enableVPN = true; # VPN management widget
    enableDynamicTheming = false; # Wallpaper-based theming (matugen)
    enableAudioWavelength = true; # Audio visualizer (cava)
    enableCalendarEvents = true; # Calendar integration (khal)
  };

  # Map the niri config files to standard location
  home.file = {
    # this is readonly
    # ".config/niri".source = config.lib.file.mkOutOfStoreSymlink "${homeModules}/niri/config";

    #and this is editable
    ".config/DankMaterialShell/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/modules/home/dankmaterialshell/settings.json";
    ".config/DankMaterialShell/plugin_settings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/modules/home/dankmaterialshell/plugin_settings.json";
    ".config/DankMaterialShell/plugins".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/modules/home/dankmaterialshell/plugins";
    ".config/DankMaterialShell/themes/cyberpunk_electric_dark.json".text = ''
            {
        "dark": {
          "name": "Cyberpunk Electric Dark",
          "primary": "#00FFCC",
          "primaryText": "#000000",
          "primaryContainer": "#00CC99",
          "secondary": "#FF4DFF",
          "surface": "#0F0F0F",
          "surfaceText": "#E0FFE0",
          "surfaceVariant": "#1F2F1F",
          "surfaceVariantText": "#CCFFCC",
          "surfaceTint": "#00FFCC",
          "background": "#000000",
          "backgroundText": "#F0FFF0",
          "outline": "#80FF80",
          "surfaceContainer": "#1A2B1A",
          "surfaceContainerHigh": "#264026",
          "surfaceContainerHighest": "#33553F",
          "error": "#FF0066",
          "warning": "#CCFF00",
          "info": "#00FFCC",
          "matugen_type": "scheme-expressive"
        },
        "light": {
          "name": "Cyberpunk Electric Light",
          "primary": "#00B899",
          "primaryText": "#FFFFFF",
          "primaryContainer": "#66FFDD",
          "secondary": "#CC00CC",
          "surface": "#F0FFF0",
          "surfaceText": "#1F2F1F",
          "surfaceVariant": "#E6FFE6",
          "surfaceVariantText": "#2D4D2D",
          "surfaceTint": "#00B899",
          "background": "#FFFFFF",
          "backgroundText": "#000000",
          "outline": "#4DCC4D",
          "surfaceContainer": "#F5FFF5",
          "surfaceContainerHigh": "#EBFFEB",
          "surfaceContainerHighest": "#E1FFE1",
          "error": "#B3004D",
          "warning": "#99CC00",
          "info": "#00B899",
          "matugen_type": "scheme-expressive"
        }
      }
    '';

    ".config/DankMaterialShell/themes/stylix.json".text = builtins.toJSON {
      dark = with colors.withHashtag; {
        name = "Stylix generatated dark theme";
        primary = base0D;
        primaryText = base00;
        primaryContainer = base0C;
        secondary = base0E;
        surface = base01;
        surfaceText = base05;
        surfaceVariant = base02;
        surfaceVariantText = base04;
        surfaceTint = base0D;
        background = base00;
        backgroundText = base05;
        outline = base03;
        surfaceContainer = base01;
        surfaceContainerHigh = base02;
        surfaceContainerHighest = base03;
        error = base08;
        warning = base0A;
        info = base0C;
      };

      light = with colors.withHashtag; {
        name = "Stylix generatated light theme";
        primary = base0D;
        primaryText = base07;
        primaryContainer = base0C;
        secondary = base0E;
        surface = base06;
        surfaceText = base01;
        surfaceVariant = base07;
        surfaceVariantText = base02;
        surfaceTint = base0D;
        background = base07;
        backgroundText = base00;
        outline = base04;
        surfaceContainer = base06;
        surfaceContainerHigh = base05;
        surfaceContainerHighest = base04;
        error = base08;
        warning = base0A;
        info = base0C;
      };
    };
  };

}
