{ pkgs, lib, ... }:
{

  home.packages = with pkgs; [
    brightnessctl
  ];
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enableXdgAutostart = true;

    settings = {
      # Autorun
      "exec-once" = [
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "waybar"
        "swaync"
        "sleep 3 && kill -9 $(pgrep \"kwalletd6|ksecretd|gnome-keyring\"); keepassxc"
        "sleep 5 && nm-applet"
        "blueman-applet"
        "wl-clipboard-history -t"
        "pasystray"
        "sleep 60 && nextcloud"
        "systemctl --user start polkit-gnome-authentication-agent-1.service"
      ];

      # Monitors
      monitor = [
        "DP-1, 2560x1440@75, 2560x0, 1"
        "DP-2, 2560x1440@75, 0x0, 1"
        "eDP-1, 3000x2000@60, 0x0, 1.666667"
        ",preferred,auto,auto"
      ];

      # Input settings
      input = {
        kb_layout = "us,ru";
        kb_options = "grp:alt_shift_toggle";
        follow_mouse = 2;
        float_switch_override_focus = 0;
        touchpad.natural_scroll = true;
        sensitivity = 0;
      };

      # Environment variables
      env = [
        "XCURSOR_SIZE,24"
        "XDG_SESSION_TYPE,wayland"
        "GDK_BACKEND,wayland,x11,*"
        "SDL_VIDEODRIVER,wayland,x11"
        "CLUTTER_BACKEND,wayland"
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_TYPE,wayland"
        "XDG_SESSION_DESKTOP,Hyprland"
      ];

      # General settings
      general = {
        gaps_in = 3;
        gaps_out = 6;
        border_size = 2;
        resize_on_border = true;
        # "col.active_border" = "rgba(7e5edcff) rgba(de00ff55) 45deg";
        # "col.inactive_border" = "rgba(595959ff)";
        layout = "master";
      };

      # Decoration
      decoration = {
        rounding = 3;
        blur = {
          enabled = true;
          size = 6;
          passes = 1;
          popups = true;
          new_optimizations = true;
        };
        blurls = [
          "rofi"
          "waybar"
        ];
        dim_inactive = false;
        dim_strength = 0.1;
        dim_around = 0.8;
        dim_special = 0.8;
        shadow = {
          range = 15;
          enabled = true;
          render_power = 2;
          # color = "0x66000000";
        };
      };

      # # Animations
      # animations = {
      #   enabled = true;
      #   bezier = {
      #     wind = "0.05, 0.9, 0.1, 1.05";
      #     winIn = "0.1, 1.1, 0.1, 1.1";
      #     winOut = "0.3, -0.3, 0, 1";
      #     liner = "1, 1, 1, 1";
      #   };
      #   animation = {
      #     windows = "1, 4, wind, slide";
      #     windowsIn = "1, 2, winIn, slide";
      #     windowsOut = "1, 4, winOut, slide";
      #     windowsMove = "1, 4, wind, slide";
      #     border = "1, 1, liner";
      #     fade = "1, 10, default";
      #     workspaces = "1, 4, wind";
      #   };
      # };

      # Layouts
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      master = {
        allow_small_split = true;
        special_scale_factor = 0.8;
        mfact = 0.6;
        new_on_top = false;
      };

      # Gestures
      gesture = "3, horizontal, workspace";

      # Key bindings
      "$term" = "kitty";
      "$browser" = "firefox";

      binde = [
        ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5-%"
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ];

      bind = [
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        "Control_L&Shift_L, Escape, exec, io.missioncenter.MissionCenter"
        "SUPER, return, exec, $term"
        "SUPER, p, exec, $HOME/.config/rofi/scripts/get_pass.sh"
        "SUPER, c, exec, $HOME/.config/rofi/scripts/edit_config.sh"
        "SUPER, o, exec, $HOME/.config/rofi/scripts/open_file.sh"
        "SUPER, slash, exec, rofi -show combi"
        "SUPER, b, exec, $browser"
        "SUPER, v, exec, $term -e nvim"
        "SUPER, e, exec, dolphin"
        "SUPER+SHIFT, p, exec, hyprpicker -a"
        ", Print, exec, $screenshotarea"
        "SUPER SHIFT, S, exec, $screenshotarea"
        "CTRL, Print, exec, grimblast --notify --cursor copysave output"
        "ALT, Print, exec, grimblast --notify --cursor copysave screen"
        "SUPER SHIFT, Q, exit,"
        "SUPER CTRL, q, exec, wlogout --protocol layer-shell -b 5 -T 400 -B 400"
        "SUPER, t, togglefloating,"
        "SUPER, f, fullscreen,"
        "SUPER CTRL, p, pseudo,"
        "SUPER, s, togglesplit,"
        "SUPER, w, killactive,"
        "SUPER, x, killactive,"
        "SUPER CTRL, p, pin"
        "SUPER, h, movefocus, l"
        "SUPER, l, movefocus, r"
        "SUPER, k, movefocus, u"
        "SUPER, j, movefocus, d"
        "SUPER CTRL, l, focusmonitor, -1"
        "SUPER CTRL, h, focusmonitor, +1"
        "SUPER SHIFT, h, movewindow, l"
        "SUPER SHIFT, l, movewindow, r"
        "SUPER SHIFT, k, movewindow, u"
        "SUPER SHIFT, j, movewindow, d"
        "SUPER SHIFT, o, movewindow, mon:+1"
        "SUPER ALT, h, resizeactive, -20 0"
        "SUPER ALT, l, resizeactive, 20 0"
        "SUPER ALT, k, resizeactive, 0 -20"
        "SUPER ALT, j, resizeactive, 0 20"
        "SUPER CTRL SHIFT, space, exec, ~/.config/hypr/scripts/toggle_wm_layout"
        "SUPER SHIFT, return, layoutmsg, swapwithmaster"
        "SUPER CTRL, m, layoutmsg, addmaster"
        "SUPER CTRL SHIFT, m, layoutmsg, removemaster"
        "SUPER CTRL SHIFT, h, layoutmsg, orientationleft"
        "SUPER CTRL SHIFT, l, layoutmsg, orientationright"
        "SUPER CTRL SHIFT, k, layoutmsg, orientationtop"
        "SUPER CTRL SHIFT, j, layoutmsg, orientationbottom"
        "SUPER CTRL SHIFT, return, layoutmsg, orientationcenter"
        "SUPER, 1, exec, ~/.config/hypr/scripts/switch_workspace 1"
        "SUPER, 2, exec, ~/.config/hypr/scripts/switch_workspace 2"
        "SUPER, 3, exec, ~/.config/hypr/scripts/switch_workspace 3"
        "SUPER, 4, exec, ~/.config/hypr/scripts/switch_workspace 4"
        "SUPER, 5, exec, ~/.config/hypr/scripts/switch_workspace 5"
        "SUPER, 6, exec, ~/.config/hypr/scripts/switch_workspace 6"
        "SUPER, 7, exec, ~/.config/hypr/scripts/switch_workspace 7"
        "SUPER, 8, exec, ~/.config/hypr/scripts/switch_workspace 8"
        "SUPER, 9, exec, ~/.config/hypr/scripts/switch_workspace 9"
        "SUPER, 0, exec, ~/.config/hypr/scripts/switch_workspace 10"
        "SUPER CTRL, j, workspace, e+1"
        "SUPER CTRL, k, workspace, e-1"
        "SUPER SHIFT, 1, movetoworkspace, 1"
        "SUPER SHIFT, 2, movetoworkspace, 2"
        "SUPER SHIFT, 3, movetoworkspace, 3"
        "SUPER SHIFT, 4, movetoworkspace, 4"
        "SUPER SHIFT, 5, movetoworkspace, 5"
        "SUPER SHIFT, 6, movetoworkspace, 6"
        "SUPER SHIFT, 7, movetoworkspace, 7"
        "SUPER SHIFT, 8, movetoworkspace, 8"
        "SUPER SHIFT, 9, movetoworkspace, 9"
        "SUPER SHIFT, 0, movetoworkspace, 10"
        "SUPER, g, togglegroup,"
        "SUPER, tab, changegroupactive,"
        "SUPER, grave, togglespecialworkspace,"
        "SUPER SHIFT, grave, movetoworkspace, special"

        "SUPER, mouse_down, workspace, e+1"
        "SUPER, mouse_up, workspace, e-1"
      ];

      "$screenshotarea" =
        "hyprctl keyword animation \"fadeOut,0,0,default\"; grimblast --notify copysave area; hyprctl keyword animation \"fadeOut,1,4,default\"";

      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];

      # Window rules
      windowrulev2 = [
        "float, class:blueman-manager"
        "float, class:stacer"
        "float, class:file_progress"
        "float, class:confirm"
        "float, class:dialog"
        "float, class:download"
        "float, class:notification"
        "float, class:error"
        "float, class:splash"
        "float, class:confirmreset"
        "float, title:Open File"
        "float, title:Открыть файл"
        "float, title:Открыть файлы"
        "float, title:Открытие файлов"
        "float, title:branchdialog"
        "float, class:Lxappearance"
        "float, class:galculator"
        "float, class:Rofi"
        "float, class:keepassxc"
        "float, class:viewnior"
        "float, class:feh"
        "float, class:pavucontrol-qt"
        "float, class:pavucontrol"
        "float, class:file-roller"
        "float, class:lxqt-policykit-agent"
        "float, title:wlogout"
        "float, title:^(.*\\ \\-\\ YouTube)$"
        "float, title:^(Media viewer)$"
        "float, title:^(Volume Control)$"
        "float, class:xdg-desktop-portal-gtk"
        "float, class:nextcloud"
        "float, class:org.gnome.Calculator"
        "float, class:polkit-kde-authentication-agent-1"
        "float, title:^(Picture-in-Picture)$"
        "float, class:Emulator"
        "float, class:org.pulseaudio.pavucontrol"
        "float, class:quickgui"
        "tile, class:Godot, initialTitle:Godot"
        "nofocus, class:REAPER, title:^$"
        "nofocus, class:Tone.ib*, title:^$"
        "stayfocused, class:steam_app_435150"
        "stayfocused, class:Tone.ib*, title: Tempo"
        "fullscreen, class:wlogout"
        "fullscreen, title:wlogout"
        "idleinhibit focus, class:mpv"
        "idleinhibit fullscreen, class:firefox"
        "idleinhibit, class:Tone.ib*, title:^$"
        "size 800 600, title:^(Volume Control)$"
        "size 450 660, class:org.gnome.Calculator"
        "size 1024 768, class:Godot, title:^(.*\\ Scene.*)$"
        "size 1024 768, class:Godot, title:^(Create New Node)$"
        "move cursor 0 5%, class:nextcloud"
        "move 100%-w-20 3%, class:nextcloud"
        "noanim, class:^(REAPER)$"
        "workspace 5, class:virt-viewer"
        "workspace 5, class:virt-manager"
        "workspace 7, class:steam"
        "workspace 2, class:google-chrome"
        "workspace 2, class:zen"
        "workspace 2, title:^(.* Яндекс\\u00A0Браузер)$"
        "workspace 5, title:^(QEMU.*)$"
        "workspace 5, class:org.remmina.Remmina"
        "workspace 5, class:spicy"
        "suppressevent maximize, class:.*"
        "dimaround, class:polkit-gnome-authentication-agent-1"
      ];

      misc = {
        focus_on_activate = true;
      };
    };
  };
}
