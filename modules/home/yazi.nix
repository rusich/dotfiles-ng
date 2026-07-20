{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    ffmpeg # for mediainfo
    mediainfo # for mediainfo
    xdg-desktop-portal-termfilechooser # use yazi as a file chooser
    trash-cli
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

    plugins = with pkgs; {
      split-tabs = yaziPlugins.split-tabs;
      clipboard = yaziPlugins.clipboard;
      smart-paste = yaziPlugins.smart-paste;
      smart-enter = yaziPlugins.smart-enter;
      mediainfo = yaziPlugins.mediainfo;
      omni-trash = unstable.yaziPlugins.omni-trash;
      mount = yaziPlugins.mount;
      easyjump = {
        package = unstable.yaziPlugins.easyjump;
        setup = true;
      };
      gvfs = {
        package = yaziPlugins.gvfs;
        setup = true;
      };
      githead = {
        package = yaziPlugins.githead;
        setup = true;
        settings = {
          branch_prefix = "on";
          branch_symbol = " ";
          branch_borders = "()";
        };
      };
      lazygit = yaziPlugins.lazygit;
      git = {
        package = yaziPlugins.git;
        setup = true;
        settings = {
          order = 1500;
        };
      };
    };

    keymap = {
      mgr.prepend_keymap = [
        # split-tabs
        {
          on = "\\";
          run = "plugin split-tabs spl_toggle";
          desc = "Split-tabs: toggle split tabs mode";
        }
        {
          on = "<Tab>";
          run = "plugin split-tabs spl_switch_tab";
          desc = "Split-tabs: switch to the other pane";
        }
        {
          on = "P";
          run = "plugin split-tabs spl_preview";
          desc = "Split-tabs: toggle preview pane";
        }

        # clipboard
        {
          on = "y";
          run = [
            "yank"
            "plugin clipboard -- --action=copy"
          ];
          desc = "Yank selected files (copy)";
        }
        {
          on = "x";
          run = [
            "yank --cut"
            "plugin clipboard -- --action=copy"
          ];
          desc = "Yank selected files (cut)";
        }
        {
          on = "<C-p>";
          run = [ "plugin clipboard -- --action=paste" ];
          desc = "Paste yanked system clipboard files";
        }
        # smart-paste
        {
          on = "p";
          run = "plugin smart-paste";
          desc = "Paste into the hovered directory or CWD";
        }
        # smart-enter
        {
          on = "l";
          run = "plugin smart-enter";
          desc = "Enter the child directory, or open the file";
        }
        # omni-trash
        {
          on = "R";
          run = "plugin omni-trash";
          desc = "Open Omni Trash";
        }
        # easyjump
        {
          on = "i";
          run = "plugin easyjump";
          desk = "easyjump";
        }
        # LazyGit
        {
          on = [
            "g"
            "i"
          ];
          run = "plugin lazygit";
          desc = "run lazygit";
        }
        # GVFS plugin
        {
          on = [
            "M"
            "m"
          ];
          run = "plugin gvfs -- select-then-mount --jump";
          desc = "Select device to mount and jump to its mount point";
        }
        {
          on = [
            "M"
            "R"
          ];
          run = "plugin gvfs -- remount-current-cwd-device";
          desc = "Remount device under cwd";
        }
        {
          on = [
            "M"
            "u"
          ];
          run = "plugin gvfs -- select-then-unmount";
          desc = "Select device then unmount";
        }
        # Or this if you want to unmount and eject device.
        #   -> Ejected device can safely be removed.
        #   -> Ejecting a device will unmount all paritions/volumes under it.
        #   -> Fallback to normal unmount if not supported by device.
        # {
        #   on = [
        #     "M"
        #     "u"
        #   ];
        #   run = "plugin gvfs -- select-then-unmount --eject";
        #   desc = "Select device then eject";
        # }

        # Also support force unmount/eject.
        #   -> Ignore outstanding file operations when unmounting or ejecting
        {
          on = [
            "M"
            "U"
          ];
          run = "plugin gvfs -- select-then-unmount --eject --force";
          desc = "Select device then force to eject/unmount";
        }

        # Add Scheme/Mount URI:
        #   -> Available schemes: mtp; gphoto2; smb; sftp; ftp; nfs; dns-sd; dav; davs; dav+sd; davs+sd; afp; afc; sshfs
        #   -> Read more about the schemes here: https://wiki.gnome.org/Projects(2f)gvfs(2f)schemes.html
        #   -> Explain about the scheme:
        #       -> If it shows like this: {ftp;ftps;ftpis;}://[user@]host[:port]
        #       -> All of the value within [] is optional. For values within {;} you must choose exactly one. All others are required.
        #       -> empty [user] or "anonymous" user is anonymous user in (ftp)
        #           -> ftp://anonymous@192.168.1.2:9999 -> skip user input step.
        #           -> ftp://192.168.1.2:9999 -> input empty value in user input box.
        #       -> Example: {ftp;ftps;ftpis;}://[user@]host[:port] => ip and port: "ftp://myusername@192.168.1.2:9999" or domain: "ftps://myusername@github.com"
        #       -> More examples: smb://user@192.168.1.2/share; smb://WORKGROUP;user@192.168.1.2/share; sftp://user@192.168.1.2/; ftp://192.168.1.2/
        # !WARNING: - Scheme/Mount URI shouldn't contain password.
        #           - Google Drive; One drive are listed automatically via GNOME Online Accounts (GOA). Avoid adding them.
        #           - MTP; GPhoto2; AFC; Hard disk/drive; fstab with x-gvfs-show are also listed automatically. Avoid adding them.
        #           - SSH; SFTP; FTP(s); AFC; DNS_SD now support [/share]. For example: sftp://user@192.168.1.2/home/user_name -> /share = /home/user_name
        #           - ssh:// is alias for sftp://.
        #             -> {sftp;ssh;}://[user@]host[:port]. Host can be Host alias in .ssh/config file; ip or domain.
        #             -> For example (home is Host alias in .ssh/config file: Host home):
        #                  -> ssh://user_name@home/home/user_name -> this will mount root path; but jump to subfolder /home/user_name
        #                  -> sftp://user_name@192.168.1.2/home/user_name -> same as above but with ip
        #                  -> sftp://user_name@192.168.1.2:9999/home/user_name -> same as above but with ip and port
        {
          on = [
            "M"
            "a"
          ];
          run = "plugin gvfs -- add-mount";
          desc = "Add a GVFS mount URI";
        }

        # Edit a Scheme/Mount URI
        #   -> Will clear saved passwords for that mount URI.
        {
          on = [
            "M"
            "e"
          ];
          run = "plugin gvfs -- edit-mount";
          desc = "Edit a GVFS mount URI";
        }

        # Remove a Scheme/Mount URI
        #   -> Will clear saved passwords for that mount URI.
        {
          on = [
            "M"
            "r"
          ];
          run = "plugin gvfs -- remove-mount";
          desc = "Remove a GVFS mount URI";
        }

        # Jump
        {
          on = [
            "g"
            "m"
          ];
          run = "plugin gvfs -- jump-to-device";
          desc = "Select device then jump to its mount point";
        }
        # If you use `x-systemd.automount` in /etc/fstab or manually added automount unit;
        # then you can use `--automount` argument to auto mount device before jump.
        # Otherwise it won't show up in the jump list.
        # {
        #   on = [
        #     "g"
        #     "m"
        #   ];
        #   run = "plugin gvfs -- jump-to-device --automount";
        #   desc = "Automount then select device to jump to its mount point";
        # }
        {
          on = [
            "`"
            "`"
          ];
          run = "plugin gvfs -- jump-back-prev-cwd";
          desc = "Jump back to the position before jumped to device";
        }

        # Automount (This is different from `x-systemd.automount` in /etc/fstab)
        #   -> Hover over any file/folder under a mounted device then run `automount-when-cd` action to enable automount when cd/jump for that device.
        #   -> When you cd/jump to unmounted device mountpoint or its sub folder; this will auto-mount the device before jump.
        #   -> Works with any command or any bookmark plugin that change cwd. For example; use `yamb` to add bookmarks and jump to them; use yazi's built-in `cd` `back` `forward` commands:

        #   -> { on = [ "m"; "a" ]; run = [ "plugin yamb -- save"; "plugin gvfs -- automount-when-cd" ]; desc = "Add bookmark and enable automount when cd";}
        {
          on = [
            "M"
            "t"
          ];
          run = "plugin gvfs -- automount-when-cd";
          desc = "Enable automount when cd to device under cwd";
        }
        {
          on = [
            "M"
            "T"
          ];
          run = "plugin gvfs -- automount-when-cd --disabled";
          desc = "Disable automount when cd to device under cwd";
        }
        # Mount plugin
        {
          on = [
            "M"
            "M"
          ];
          run = "plugin mount";
          desc = "Mount Local Device";
        }
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

      # plugins registration
      plugin = {
        # Preloades
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
        # Previewers
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
        # Fetchers
        prepend_fetchers = [
          # git
          {
            url = "*";
            run = "git";
            group = "git";
          }
          {
            url = "*/";
            run = "git";
            group = "git";
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
