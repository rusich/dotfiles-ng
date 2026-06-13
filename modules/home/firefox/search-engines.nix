{ pkgs, ... }:

let
  # Общая иконка для всех Nix-сервисов
  nixIcon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";

  # Фикс: правильные URL с https://
  youtubeIcon = pkgs.fetchurl {
    url = "https://www.youtube.com/s/desktop/8498231a/img/favicon_144x144.png";
    sha256 = "sha256-lQ5gbLyoWCH7cgoYcy+WlFDjHGbxwB8Xz0G7AZnr9vI=";
  };

  redditIcon = pkgs.fetchurl {
    url = "https://www.redditstatic.com/accountmanager/favicon/favicon-512x512.png";
    sha256 = "sha256-4zWTcHuL1SEKk8KyVFsOKYPbM4rc7WNa9KrGhK4dJyg=";
  };

  githubIcon = pkgs.fetchurl {
    url = "https://github.githubassets.com/favicons/favicon.svg";
    sha256 = "sha256-apV3zU9/prdb3hAlr4W5ROndE4g3O1XMum6fgKwurmA=";
  };
in

{
  # Все поисковые движки
  "GitHub" = {
    urls = [
      {
        template = "https://github.com/search";
        params = [
          {
            name = "q";
            value = "{searchTerms}";
          }
        ];
      }
    ];
    icon = githubIcon;
    definedAliases = [ "@gh" ];
  };

  "Nix Packages" = {
    urls = [
      {
        template = "https://search.nixos.org/packages";
        params = [
          {
            name = "channel";
            value = "unstable";
          }
          {
            name = "query";
            value = "{searchTerms}";
          }
        ];
      }
    ];
    icon = nixIcon;
    definedAliases = [ "@np" ];
  };

  "Nix Options" = {
    urls = [
      {
        template = "https://search.nixos.org/options";
        params = [
          {
            name = "channel";
            value = "unstable";
          }
          {
            name = "query";
            value = "{searchTerms}";
          }
        ];
      }
    ];
    icon = nixIcon;
    definedAliases = [ "@no" ];
  };

  "NixOS Wiki Official" = {
    urls = [
      {
        template = "https://wiki.nixos.org/w/index.php";
        params = [
          {
            name = "search";
            value = "{searchTerms}";
          }
        ];
      }
    ];
    icon = nixIcon;
    definedAliases = [ "@nwo" ];
  };

  "NixOS Wiki Unofficial" = {
    urls = [
      {
        template = "https://nixos.wiki/index.php";
        params = [
          {
            name = "search";
            value = "{searchTerms}";
          }
        ];
      }
    ];
    icon = nixIcon;
    definedAliases = [ "@nwu" ];
  };

  "Nixpkgs Issues" = {
    urls = [
      {
        template = "https://github.com/NixOS/nixpkgs/issues";
        params = [
          {
            name = "q";
            value = "{searchTerms}";
          }
        ];
      }
    ];
    icon = nixIcon;
    definedAliases = [ "@ni" ];
  };

  "MyNixOS" = {
    urls = [
      {
        template = "https://mynixos.com/search";
        params = [
          {
            name = "q";
            value = "{searchTerms}";
          }
        ];
      }
    ];
    icon = nixIcon;
    definedAliases = [ "@ny" ];
  };

  # Замените "Nixhub" на:
  "Nixhub" = {
    urls = [
      {
        template = "https://www.nixhub.io/search";
        params = [
          {
            name = "q";
            value = "{searchTerms}";
          }
        ];
      }
    ];
    icon = nixIcon;
    definedAliases = [ "@nh" ];
  };

  "HM options" = {
    urls = [
      {
        template = "https://home-manager-options.extranix.com/";
        params = [
          {
            name = "query";
            value = "{searchTerms}";
          }
        ];
      }
    ];
    icon = nixIcon;
    definedAliases = [ "@nm" ];
  };

  "Nix func" = {
    urls = [
      {
        template = "https://noogle.dev/q";
        params = [
          {
            name = "term";
            value = "{searchTerms}";
          }
        ];
      }
    ];
    icon = nixIcon;
    definedAliases = [ "@nf" ];
  };

  "reddit" = {
    urls = [
      {
        template = "https://www.reddit.com/search";
        params = [
          {
            name = "q";
            value = "{searchTerms}";
          }
        ];
      }
    ];
    icon = redditIcon;
    definedAliases = [ "@r" ];
  };

  "Youtube" = {
    urls = [
      {
        template = "https://www.youtube.com/results";
        params = [
          {
            name = "search_query";
            value = "{searchTerms}";
          }
        ];
      }
    ];
    icon = youtubeIcon;
    definedAliases = [ "@y" ];
  };
}
