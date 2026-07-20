{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    ffmpeg # for mediainfo
    mediainfo # for mediainfo
    xdg-desktop-portal-termfilechooser # use yazi as a file chooser
  ];

  # Termfilechooser config
  home.file.".config/xdg-desktop-portal-termfilechooser/config".text = ''
    [filechooser]
    cmd=${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
    default_dir=$HOME
    create_help_file=1
    env=TERMCMD='kitty --title filechooser'
    env=PATH="$PATH:/run/current-system/sw/bin"
    open_mode = suggested
    save_mode = last
  '';

  # Подключаем termfilechooser как FileChooser портал
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-termfilechooser ];
  xdg.portal.config.common."org.freedesktop.impl.portal.FileChooser" = lib.mkForce "termfilechooser";

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    shellWrapperName = "y";

    plugins = {
      mediainfo = pkgs.yaziPlugins.mediainfo;
    };

    vfs = {
      services = {
        truenas = {
          type = "sftp";
          host = "truenas";
          user = "root";
          port = 22;
        };
      };
    };

    keymap = {
      mgr.prepend_keymap = [
        {
          run = "cd sftp://truenas";
          on = [
            "g"
            "t"
          ];
          desc = "Go to TrueNAS";
        }
        {
          on = [ "!" ];
          for = "unix";
          run = "shell \"$SHELL\" --block";
          desc = "Open $SHELL here";
        }
      ];
    };

    settings = {

      open = {
        prepend_rules = [
          {
            mime = "image/*";
            use = [
              "open"
              "set-wallpaper"
            ];
          }
        ];
      };

      # set wallpeperr in noctalia shell
      opener = {
        set-wallpaper = [
          {
            run = "noctalia msg wallpaper-set %s1";
            for = "linux";
            desc = "Set as wallpaper";
          }
        ];
      };

      plugin = {
        prepend_preloaders = [
          # Replace magick, image, video with mediainfo
          {
            mime = "{audio,video,image}/*";
            run = "mediainfo";
          }
          {
            mime = "application/subrip";
            run = "mediainfo";
          }
          # Adobe Illustrator, Adobe Photoshop is image/adobe.photoshop, already handled above
          {
            mime = "application/postscript";
            run = "mediainfo";
          }
        ];
        prepend_previewers = [
          # Replace magick, image, video with mediainfo
          {
            mime = "{audio,video,image}/*";
            run = "mediainfo";
          }
          {
            mime = "application/subrip";
            run = "mediainfo";
          }
          # Adobe Illustrator, Adobe Photoshop is image/adobe.photoshop, already handled above
          {
            mime = "application/postscript";
            run = "mediainfo";
          }
        ];
      };
      # There are more extensions which are supported by mediainfo.
      # Just add file's MIME type to `previewers`, `preloaders` above.
      # https://mediaarea.net/en/MediaInfo/Support/Formats

      # For a large file like Adobe Illustrator, Adobe Photoshop, etc
      # you may need to increase the memory limit if no image is rendered.
      # https://yazi-rs.github.io/docs/configuration/yazi#tasks
      tasks = {
        image_alloc = 1073741824; # = 1024*1024*1024 = 1024MB
      };
    };
  };
}
