# Cross-platform base packages for every machine (including servers).
{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    # fonts
    nerd-fonts.iosevka
    nerd-fonts.iosevka-term
    nerd-fonts.fantasque-sans-mono
    # base CLI
    mdcat
    xdg-user-dirs
    libsecret
    cht-sh
    luarocks
    libnotify
    delta
    jq
    fd
    eza
    nodejs_24
    just
  ];
}
