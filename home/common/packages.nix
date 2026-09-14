# Cross-platform base packages for every machine (including servers).
# Desktop/dev-only tools live in the gui/dev features (enabled by bundles/graphical).
{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    xdg-user-dirs
    delta
    jq
    fd
    eza
  ];
}
