{
  pkgs,
  ...
}:
{
  services.vdirsyncer.enable = true;
  programs.vdirsyncer.enable = true;

  # Gnome online accounts must be enabled in NixOS configuration
  # ../../modules/nixos/desktopCommon/gnome-online-accounts.nix
  home.packages = with pkgs; [
    gnome-calendar
  ];

  programs.khal = {
    enable = true;
    locale = {
      timeformat = "%H:%M";
      dateformat = "%Y-%m-%d";
      longdateformat = "%Y-%m-%d";
      datetimeformat = "%Y-%m-%d %H:%M";
      longdatetimeformat = "%Y-%m-%d %H:%M";
    };
    settings = {
      default = {
        default_calendar = "personal";
        timedelta = "7d";
        highlight_event_days = true;
      };
      view = {
        agenda_event_format = "{calendar-color}{cancelled}{start-end-time-style} {title}{repeat-symbol}{reset}";
      };
    };

  };

  accounts.calendar = {
    basePath = ".calendars";
  };

  accounts.calendar.accounts.nextcloud = {
    remote = {
      type = "caldav";
      passwordCommand = [
        "secret-tool"
        "lookup"
        "short"
        "NEXTCLOUD_PASSWORD"
      ];
    };

    khal = {
      enable = true;
      type = "discover";
    };

    vdirsyncer = {
      enable = true;
      metadata = [ "color" ];
      collections = [
        "personal"
        "work"
        "google"
        "contact_birthdays"
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
