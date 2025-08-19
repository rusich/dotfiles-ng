{ pkgs, stylix, ... }: {

  stylix.enable = true;
  stylix.base16Scheme =
    "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
  # "${pkgs.base16-schemes}/share/themes/windows-10-light.yaml";
  # "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

}
