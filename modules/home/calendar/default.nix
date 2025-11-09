{
  inputs,
  pkgs,
  config,
  homeModules,
  ...
}:
{
  services.vdirsyncer = {
    enable = true;
  };

  home.packages = with pkgs; [
    khal
    vdirsyncer
  ];

  # programs.khal = {
  #   enable = true;
  # };

  home.file = {
    # khal
    ".config/khal/config".source =
      config.lib.file.mkOutOfStoreSymlink "${homeModules}/calendar/khal_config.toml";
    # vdirsyncer
    ".config/vdirsyncer/config".source =
      config.lib.file.mkOutOfStoreSymlink "${homeModules}/calendar/vdirsyncer_config.toml";
  };

  # accounts.calendar = {
  #   basePath = ".calendars";
  # };
  #
  # accounts.calendar.accounts.nextcloud = {
  #   remote = {
  #     type = "caldav";
  #     url = "https://nextcloud.rusich.pw";
  #     userName = "rusich";
  #     # urlCommand = "secret-tool lookup short NEXTCLOUD_URL";
  #     # userNameCommand = "secret-tool lookup short NEXTCLOUD_USERNAME";
  #     passwordCommand = "secret-tool lookup short NEXTCLOUD_PASSWORD";
  #   };
  #
  #   vdirsyncer = {
  #     enable = true;
  #     collections = [
  #       "personal"
  #       "work"
  #     ];
  #     # urlCommand = "secret-tool lookup short NEXTCLOUD_URL";
  #     # userNameCommand = "secret-tool lookup short NEXTCLOUD_USERNAME";
  #   };
  # };
  #
  # accounts.calendar.accounts.khal = {
  #   primary = true;
  #   khal = {
  #     enable = true;
  #     type = "discover";
  #   };
  #
  # };
}
