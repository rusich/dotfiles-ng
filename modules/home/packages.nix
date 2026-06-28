# User only packages
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # desktop
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
    # waybar
    # waylock
    # wlogout
    # wpaperd
    # misc
    grimblast
    # base
    vlc
    mdcat
    xdg-user-dirs
    playerctl
    libsecret
    gnome-calculator
    cht-sh
    luarocks
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
    chatbox
    unrar
    unetbootin
    just
    # Gnome apps for test
    showtime
    mpv
    decibels
    loupe
    papers
    telegram-desktop
    calibre
  ];
}
