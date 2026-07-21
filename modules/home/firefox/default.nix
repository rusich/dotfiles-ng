{
  config,
  pkgs,
  inputs,
  ...
}:
{
  programs.firefox = {
    enable = true;
    configPath = "${config.xdg.configHome}/mozilla/firefox";
    nativeMessagingHosts = [
      pkgs.pywalfox-native
    ];
    profiles.${config.home.username} = {
      settings = {
        "dom.security.https_only_mode" = true;
        "browser.translations.enable" = false;
        "signon.rememberSignons" = true;
        "signon.rememberSignons.visibility" = false;
        "browser.places.importBookmarksHTML" = false;
        "browser.bookmarks.autoExportHTML" = false;
        # Look'n'feel
        "sidebar.verticalTabs" = true;
        "browser.toolbars.bookmarks.visibility" = "never";
        "identity.fxaccounts.enabled" = false;

        # Приватность
        "privacy.donottrackheader.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.sanitize.sanitizeOnShutdown" = false;
        "privacy.clearOnShutdown_v2.formdata" = false;

        # Производительность
        "browser.sessionhistory.max_entries" = 50; # стандарт 50, но можно уменьшить
        "browser.sessionstore.interval" = 15000; # интервал сохранения сессий (мс)

        # Открытие папок через системный файловый менеджер (Yazi)
        "browser.download.dir" = true;
        "browser.download.useDownloadDir" = false;

        # Отключить телеметрию Mozilla
        "toolkit.telemetry.enabled" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "browser.ping-centre.telemetry" = false;
      };

      extensions = {
        force = true; # только явно перечисленные расширения
        packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
          keepassxc-browser
          simple-translate
          floccus
          firefox-color
          pywalfox
        ];
      };

      search = {
        force = true;
        default = "google";
        order = [
          "google"
          "ddg"
        ];
        engines = {
          "bing".metaData.hidden = true;
          "google".metaData.alias = "@g";
          "wikipedia".metaData.alias = "@w";
          "ddg" = {
            urls = [ { template = "https://duckduckgo.com/?q={searchTerms}"; } ];
            definedAliases = [ "@ddg" ];
          };
        }
        # Импортируем все поисковые движки из отдельного файла
        // (import ./search-engines.nix { inherit pkgs; });
      };
    };
  };
}
