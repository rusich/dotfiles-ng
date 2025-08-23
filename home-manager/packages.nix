{
  config,
  pkgs,
  unstable,
  nixpkgs,
  ...
}:

{

  home.packages = with pkgs; [
    # desktop
    kdePackages.breeze
    libsForQt5.qt5ct
    qt6ct
    breeze-hacked-cursor-theme
    whitesur-gtk-theme
    whitesur-icon-theme
    nwg-look
    # fonts
    nerd-fonts.iosevka
    nerd-fonts.iosevka-term
    nerd-fonts.fantasque-sans-mono
    # kde packagers
    kdePackages.dolphin
    kdePackages.dolphin-plugins
    # unstable
    unstable.opencode
    # wayland
    rofi-wayland
    wofi
    swaynotificationcenter
    waybar
    waylock
    wlogout
    hyprlock
    hypridle
    wpaperd
    blueman
    # base
    vlc
    nixfmt-rfc-style
    nixd
    mdcat
    xdg-user-dirs
    playerctl
    libsecret
    gnome-calculator
    cht-sh
    wl-clipboard
    luarocks
    rustup
    libnotify
    ripgrep
    fzf
    delta
    jq
    pamixer
    pavucontrol
    keepassxc
    nextcloud-client
    yazi
    ncdu
    nautilus
    nautilus-python
    nautilus-open-any-terminal
    fd
    eza
    networkmanagerapplet
  ];

}
