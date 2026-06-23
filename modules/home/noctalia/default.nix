{
  inputs,
  pkgs,
  ...
}:
{

  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia = {
    enable = true;
    settings = {
      audio = {
        enable_overdrive = true;
        enable_sounds = true;
      };
      bar = {
        default = {
          capsule = true;
          center = [ "group:g2" ];
          end = [
            "tray"
            "notifications"
            "clipboard"
            "network"
            "bluetooth"
            "volume"
            "brightness"
            "battery"
            "control-center"
            "session"
          ];
          margin_edge = 4;
          margin_ends = 4;
          radius = 8;
          widget_spacing = 10;
          capsule_group = [
            {
              fill = "surface_variant";
              id = "g1";
              members = [
                "clock"
                "media"
              ];
              opacity = 1.0;
              padding = 6.0;
            }
            {
              fill = "surface_variant";
              id = "g2";
              members = [
                "clock"
                "media"
              ];
              opacity = 1.0;
              padding = 6.0;
            }
          ];
        };
      };
      calendar = {
        enabled = true;
      };
      dock = {
        enabled = false;
      };
      location = {
        auto_locate = true;
      };
      osd = {
        position = "bottom_center";
      };
      shell = {
        font_family = "DejaVu Sans Condensed";
        niri_overview_type_to_launch_enabled = true;
        polkit_agent = true;
        panel = {
          control_center_placement = "floating";
          open_near_click_control_center = true;
          session_placement = "centered";
          transparency_mode = "soft";
        };
        screen_corners = {
          size = 54;
        };
        shadow = {
          direction = "center";
        };
      };
      wallpaper = {
        directory = "/home/rusich/Nextcloud/Pictures/Wallpapers/";
      };
      widget = {
        clock = {
          format = "{:%d-%m-%Y %H:%M}";
          scale = 1.1500000000000001;
        };
        tray = {
          capsule = true;
          drawer = true;
        };
      };
      theme = {
        templates = {
          builtin_ids = [
            "btop"
            "gtk3"
            "gtk4"
            "kcolorscheme"
            "kitty"
            "niri"
            "qt"
          ];
          community_ids = [
            "steam"
            "yazi"
          ];
        };
      };

      # Widgets
      lockscreen_widgets = {
        enabled = true;
        schema_version = 2;
        widget_order = [
          "lockscreen-login-box@DP-2"
          "lockscreen-login-box@DP-1"
        ];
        grid = {
          cell_size = 16;
          major_interval = 4;
          visible = true;
        };
        widget = {
          "lockscreen-login-box@DP-1" = {
            box_height = 70.0;
            box_width = 400.0;
            cx = 1280.0;
            cy = 1321.0;
            output = "DP-1";
            rotation = 0.0;
            type = "login_box";
            settings = {
              background_color = "surface_variant";
              background_opacity = 0.88;
              background_radius = 12.0;
              input_opacity = 1.0;
              input_radius = 6.0;
              show_login_button = true;
            };
          };
          "lockscreen-login-box@DP-2" = {
            box_height = 70.0;
            box_width = 400.0;
            cx = 1280.0;
            cy = 1321.0;
            output = "DP-2";
            rotation = 0.0;
            type = "login_box";
            settings = {
              background_color = "surface_variant";
              background_opacity = 0.88;
              background_radius = 12.0;
              input_opacity = 1.0;
              input_radius = 6.0;
              show_login_button = true;
            };
          };
        };
      };
    };
  };

  home.packages = with pkgs; [
    adw-gtk3
    nwg-look
    kdePackages.qt6ct
    libsForQt5.qt5ct
    pywalfox-native
  ];

  # set environment variables
  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt6ct";
    TESSSST = "sdfsfaf";
  };

  home.activation.setAdwGtk3Theme = inputs.nixpkgs.lib.mkAfter ''
    ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3' || true
  '';
}
