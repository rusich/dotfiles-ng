# User only packages
{
  pkgs,
  ...
}:

{

  home.packages = with pkgs; [
    # desktop
    # libsForQt5.qt5ct
    # qt6ct
    # breeze-hacked-cursor-theme
    whitesur-gtk-theme
    whitesur-icon-theme
    nwg-look
    # yandex-music
    # inputs.yandex-browser.packages.x86_64-linux.yandex-browser-stable
    # fonts
    nerd-fonts.iosevka
    nerd-fonts.iosevka-term
    nerd-fonts.fantasque-sans-mono
    kdePackages.breeze
    # wayland
    rofi
    # swaynotificationcenter
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
    luarocks
    # rustup
    cargo
    # rustc
    libnotify
    delta
    jq
    pamixer
    keepassxc
    ncdu
    fd
    eza
    networkmanagerapplet
    nodejs_24
    discord
    wl-clipboard
    unstable.chatbox
    unrar
    unetbootin
  ];

}
