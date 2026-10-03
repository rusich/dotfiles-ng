{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.user.pim.contacts;
in
{
  options.user.pim.contacts.enable = lib.mkEnableOption "contacts (vdirsyncer + khard)";

  config = lib.mkIf cfg.enable {
    services.vdirsyncer.enable = true;
    programs.vdirsyncer.enable = true;
    programs.khal.enable = true;
    programs.khard.enable = true;

    # Gnome online accounts must be enabled in NixOS configuration
    # ../../modules/nixos/desktopCommon/gnome-online-accounts.nix
    home.packages = with pkgs; [
      gnome-contacts
    ];

    accounts.contact = {
      basePath = ".contacts";
    };

    accounts.contact.accounts.nextcloud = {
      local = {
        encoding = "UTF-8";

      };
      remote = {
        type = "carddav";
        passwordCommand = [
          "${pkgs.coreutils}/bin/cat"
          config.sops.secrets."nextcloud/password".path
        ];
      };

      khard = {
        enable = true;
        addressbooks = "default";
      };

      khal = {
        # Можно напрямую с контактов подтякивать даты рождения.
        # Не надо, так как NC уже создает необходимый календарь
        enable = false;
        readOnly = true;
        color = "#ff0000";
        collections = [
          "default"
        ];
      };

      vdirsyncer = {
        enable = true;
        collections = [
          "default"
        ];

        urlCommand = [
          "${pkgs.coreutils}/bin/cat"
          config.sops.secrets."nextcloud/url".path
        ];
        userNameCommand = [
          "${pkgs.coreutils}/bin/cat"
          config.sops.secrets."nextcloud/username".path
        ];
      };
    };

    # sops-nix decrypts user secrets in sops-nix.service; wait for it before
    # vdirsyncer reads the password/url/username files.
    systemd.user.services.vdirsyncer.Unit.After = [ "sops-nix.service" ];
  };
}
