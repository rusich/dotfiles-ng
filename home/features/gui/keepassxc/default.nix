{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.user.gui.keepassxc;
in
{
  options.user.gui.keepassxc.enable = lib.mkEnableOption "keepassxc";

  config = lib.mkIf cfg.enable {
    programs.keepassxc = {
      enable = true;
      # autostart = true;
    };

    home.file = {
      # out-of-store: KeePassXC rewrites its config when settings change.
      ".config/keepassxc/keepassxc.ini".source =
        config.lib.file.mkOutOfStoreSymlink config.homeModulesPath
        + "/features/gui/keepassxc/keepassxc.ini";

      # Mask gnome-keyring's XDG autostart for THIS user only (other users keep
      # gnome-keyring). Its OnlyShowIn is commented out upstream, so it would
      # start in any session and grab org.freedesktop.secrets, making KeePassXC
      # disable its FdoSecrets.
      ".config/autostart/gnome-keyring-secrets.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=gnome-keyring-secrets (masked; KeePassXC is the Secret Service)
        Hidden=true
      '';
      ".config/autostart/gnome-keyring-pkcs11.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=gnome-keyring-pkcs11 (masked)
        Hidden=true
      '';

      # gnome-keyring's D-Bus activation file would re-spawn it whenever
      # something asks for org.freedesktop.secrets. This per-user file shadows
      # the system-wide one (XDG_DATA_HOME has higher precedence), so activation
      # is a no-op and KeePassXC keeps the name exclusively.
      ".local/share/dbus-1/services/org.freedesktop.secrets.service".text = ''
        [D-BUS Service]
        Name=org.freedesktop.secrets
        Exec=${pkgs.coreutils}/bin/false
      '';
    };

    # Auto-unlock KeePassXC at login with the database password from sops-nix
    # (no manual entry). A user service keeps it self-contained and ordered
    # after sops-nix.service; niri imports the Wayland session environment into
    # the user manager (systemctl --user import-environment), so the GUI gets
    # WAYLAND_DISPLAY.
    systemd.user.services.keepassxc-autounlock = lib.mkIf config.user.secrets.enable {
      Unit = {
        Description = "KeePassXC (auto-unlock with sops-nix secret)";
        After = [
          "graphical-session.target"
          "sops-nix.service"
        ];
        PartOf = [ "graphical-session.target" ];
        Requires = [ "sops-nix.service" ];
      };
      Service = {
        Type = "simple";
        ExecStart = pkgs.writeShellScript "keepassxc-autounlock" ''
          exec ${pkgs.keepassxc}/bin/keepassxc --minimized --pw-stdin \
            "${config.home.homeDirectory}/Nextcloud/Configs/Passwords.kdbx" \
            < "${config.sops.secrets."keepass/database-password".path}"
        '';
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
