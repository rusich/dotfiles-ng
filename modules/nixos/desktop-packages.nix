# Common desktop packages for all hosts and users
{ pkgs, config, ... }:
{

  environment.systemPackages = with pkgs; [
    gcc
    python3
    home-manager
    libreoffice
    kitty
    hunspell
    hunspellDicts.en_US
    hunspellDicts.ru_RU
    gparted
    gimp
    nextcloud-client
    # Nautilus + dependencies
    nautilus
    nautilus-python # for nextcloud integration
    nautilus-open-any-terminal
    firefox
    # misc
    xkill
  ];

  # Let nautilus find extensions
  environment.sessionVariables.NAUTILUS_4_EXTENSION_DIR = "${config.system.path}/lib/nautilus/extensions-4";
  environment.pathsToLink = [
    "/share/nautilus-python/extensions"
  ];

}
