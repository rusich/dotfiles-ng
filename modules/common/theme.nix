{ pkgs, stylix, ... }:
{

  stylix = {
    enable = true;
    targets = {
      gtk.enable = true;
      qt.enable = true;
    };
  };

  stylix.polarity = "dark";
  stylix.base16Scheme =
    # "${pkgs.base16-schemes}/share/themes/oxocarbon-dark.yaml";
    # "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    # "${pkgs.base16-schemes}/share/themes/windows-10-light.yaml";
    "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

}
