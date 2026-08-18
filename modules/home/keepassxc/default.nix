{
  pkgs,
  config,
  ...
}:
{
  programs.keepassxc = {
    enable = true;
    # autostart = true;
  };

  # home.packages = with pkgs; [
  #   keepassxc
  # ];
  #
  # # Map the niri config files to standard location
  home.file = {
    ".config/keepassxc/keepassxc.ini".source =
      config.lib.file.mkOutOfStoreSymlink config.homeModulesPath + "/keepassxc/keepassxc.ini";
  };
  #
  # # To run as system keyring agent need to disable other keyring agents
  # services.gnome-keyring = pkgs.lib.mkForce { enable = false; }; # also need to disable in nixos config
  #
  # # gnome-keyring package is still installed system-wide (dependency of
  # # gnome-shell used by other users), so its D-Bus activation file
  # # org.freedesktop.secrets.service is present in the session bus and
  # # dbus-daemon re-spawns gnome-keyring-daemon whenever secret-tool (libsecret)
  # # asks for org.freedesktop.secrets. This per-user service file shadows the
  # # system-wide one (XDG_DATA_HOME has higher precedence), so activation is
  # a no-op and KeepassXC keeps the name exclusively.
  home.file.".local/share/dbus-1/services/org.freedesktop.secrets.service".text = ''
    [D-BUS Service]
    Name=org.freedesktop.secrets
    Exec=${pkgs.coreutils}/bin/false
  '';
}
