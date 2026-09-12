# User only packages
{
  pkgs,
  lib,
  ...
}:
{
  home.packages =
    with pkgs;
    [
      # desktop
      # breeze-hacked-cursor-theme
      whitesur-gtk-theme
      # fonts
      nerd-fonts.iosevka
      nerd-fonts.iosevka-term
      nerd-fonts.fantasque-sans-mono
      # base
      mdcat
      xdg-user-dirs
      libsecret
      gnome-calculator
      cht-sh
      luarocks
      libnotify
      delta
      jq
      keepassxc
      fd
      eza
      nodejs_24
      discord
      just
      # Gnome apps for test
      showtime
      mpv
      # zathura # Document viewer
      telegram-desktop
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      # Linux-only packages
      whitesur-icon-theme
      nwg-look
      rofi
      pamixer
      networkmanagerapplet
      unetbootin
      kdePackages.breeze
      playerctl
      decibels
      calibre
      grimblast
      vlc
      wl-clipboard
      chatbox
      loupe
      papers
      custom.freelib
    ];
}
