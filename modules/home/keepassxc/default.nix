{
  inputs,
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    keepassxc
  ];

  # Map the niri config files to standard location
  home.file = {
    ".config/keepassxc/keepassxc.ini".source =
      config.lib.file.mkOutOfStoreSymlink config.homeModulesPath + "/keepassxc/keepassxc.ini";
  };

  # To run as system keyring agent need to disable other keyring agents
  services.gnome-keyring = pkgs.lib.mkForce {enable = false;}; # also need to disable in nixos config
}
