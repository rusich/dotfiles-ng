# Common desktop packages for all hosts and users
{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    gcc
    python3
    home-manager
    sddm-chili-theme
    sddm-astronaut
    sddm-sugar-dark
    libreoffice
    kitty
    hunspell
    hunspellDicts.en_US
    hunspellDicts.ru_RU
    gparted
    gimp
    nextcloud-client
    nautilus
    nautilus-python
    nautilus-open-any-terminal
    # kde package
    kdePackages.dolphin
    kdePackages.dolphin-plugins
    kdePackages.qtsvg # for dolphin
    kdePackages.kio-extras
  ];

}
