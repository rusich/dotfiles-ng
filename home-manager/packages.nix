{
  config,
  pkgs,
  unstable,
  inputs,
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
    # yandex-music
    inputs.yandex-browser.packages.x86_64-linux.yandex-browser-stable
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
    # misc
    grimblast
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
    # rustup
    # cargo
    # rustc
    libnotify

    delta
    jq
    pamixer
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
    nodejs_24
  ];

}
