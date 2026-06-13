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
    profiles.${config.home.username} = {
      settings = {
        "dom.security.https_only_mode" = true;
        "browser.translations.enable" = false;
        "signon.rememberSignons" = false;
        "browser.places.importBookmarksHTML" = false;
        "browser.bookmarks.autoExportHTML" = false;
        # Look'n'feel
        "sidebar.verticalTabs" = true;
        "browser.toolbars.bookmarks.visibility" = "never";
        "identity.fxaccounts.enabled" = false;

        # Приватность
        "privacy.donottrackheader.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
        # "privacy.sanitize.sanitizeOnShutdown" = true;

        # Производительность
        "browser.sessionhistory.max_entries" = 50; # стандарт 50, но можно уменьшить
        "browser.sessionstore.interval" = 15000; # интервал сохранения сессий (мс)

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
            # ← добавить
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
