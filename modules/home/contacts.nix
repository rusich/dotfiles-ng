{
  pkgs,
  ...
}:
{
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
        "secret-tool"
        "lookup"
        "short"
        "NEXTCLOUD_PASSWORD"
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
        "secret-tool"
        "lookup"
        "short"
        "NEXTCLOUD_URL"
      ];
      userNameCommand = [
        "secret-tool"
        "lookup"
        "short"
        "NEXTCLOUD_USERNAME"
      ];
    };
  };

}
