# Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

from typing import List  # noqa: F401
import os
import subprocess
import socket

from libqtile import hook, qtile, bar, layout, widget
from libqtile.config import (
    Click,
    Drag,
    Group,
    ScratchPad,
    DropDown,
    Key,
    KeyChord,
    Match,
    Screen,
)
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal

import arcobattery
import lattoruskeys

# Common Qtile settings
dgroups_key_binder = None
dgroups_app_rules = []  # type: List
# follow_mouse_focus = True
follow_mouse_focus = False
bring_front_click = False
# bring_front_click = True
cursor_warp = False
# cursor_warp = True
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True
# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True
switch_to_group_on_move = False

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
# wmname = "qtile"

# VARIABLES
WLAN_ADAPTER = next(
    iter([w for w in os.listdir("/sys/class/net/") if "wl" in w]), "no wlan"
)
ETH_ADAPTER = next(
    iter([w for w in os.listdir("/sys/class/net/") if "e" in w]), "no eth"
)
HAVE_BATTERY = len(os.listdir("/sys/class/power_supply/")) > 0
HOSTNAME = socket.gethostname()
mod = "mod4"
# terminal = guess_terminal()
terminal = "kitty"

# LOOK & FEEL
FONT_SIZE = 14
if HOSTNAME == "matebook":
    FONT_SIZE = 24

SEPARATOR_PADDING = 10
SEPARATOR_LINEWIDTH = 1

# COLORS
THEME_COLORS = {
    "background": "#000000",
    "foreground": "#ffffff",
    "active": "#ffffff",
    "inactive": "#7a7473",
    "hilight": "#141414",
    "current_border": "#e1acff",
    "border": "#74438f",
    "separator": "#74438f",
}

colors = [
    ["#282c34", "#282c34"],  # 0 panel background
    ["#3d3f4b", "#434758"],  # 1 background for current screen tab
    ["#ffffff", "#ffffff"],  # 2 font color for group names
    ["#ff5555", "#ff5555"],  # 3 border line color for current tab
    # 4 border line color for 'other tabs' and color for 'odd widgets'
    ["#74438f", "#74438f"],
    ["#4f76c7", "#4f76c7"],  # 5 color for the 'even widgets'
    ["#e1acff", "#e1acff"],  # 6 window name
    ["#ecbbfb", "#ecbbfb"],
]  # 7 backbround for inactive screens

# Layout theme
layouts_theme = {
    "border_width": 2,
    "margin": 1,
    "border_focus": THEME_COLORS["current_border"],
    # "border_normal": "1d2330"
    "border_normal": THEME_COLORS["border"],
}


# Widgets theme
widget_defaults = dict(
    font="FontAwesome",
    fontsize=FONT_SIZE,
    padding=2,
    background=THEME_COLORS["background"],
    foreground=THEME_COLORS["foreground"],
)
# extension_defaults = widget_defaults.copy() #for bar?

# BAR SETTINGS
bar_settings = {
    "opacity": 0.7,
    "size": FONT_SIZE + 18,
    #         [T, R, B, L]
    "margin": [-1, -2, 0, -4],
    # 'margin': [4, 4, 0, 4],
}

# END OF LOOK & FEEL

# KEY BINDINGS
keys = [
    # Launch terminal
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    # Change keyboard layout
    # Key(["control"], "Shift_L", lazy.widget["keyboardlayout"].next_keyboard(), desc="Next keyboard layout."),
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key(
        [mod, "control"],
        "space",
        lazy.layout.next(),
        desc="Move window focus to other window",
    ),  # default <mod> space
    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key(
        [mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"
    ),
    Key(
        [mod, "shift"],
        "l",
        lazy.layout.shuffle_right(),
        desc="Move window to the right",
    ),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key(
        [mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"
    ),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod, "control"], "a", lazy.layout.grow(), desc="Grow window"),
    Key([mod, "control"], "s", lazy.layout.shrink(), desc="Shrink window"),
    Key([mod, "control"], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key(
        [mod, "shift"],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_screen(), desc="Toggle next layout"),
    Key([mod, "shift"], "Tab", lazy.next_layout(), desc="Toggle next layout"),
    Key([mod, "control"], "Tab", lazy.prev_layout(), desc="Toggle prev layout"),
    # Key([mod, "shift"], "Tab", lazy.prev_layout(), desc="Toggle prev layout"),
    Key([mod], "w", lazy.window.kill(), desc="Kill focused window"),
    Key([mod, "control"], "r", lazy.restart(), desc="Restart Qtile"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
    Key([mod], "m", lazy.spawn("rofi -show"), desc="Spawn a rofi menu"),
    Key(
        [mod, "shift"],
        "m",
        lazy.spawn("rofi -show drun -run-shell-command '{terminal} -e {cmd}'"),
        desc="Spawn a rofi menu, then run selected program in a terminal window",
    ),
    # Key([mod], "e", lazy.spawn("dmenu_run"),
    #    desc="Spawn a command using a prompt widget"),
    Key(
        [mod],
        "e",
        lazy.spawn(os.path.expanduser("~/.config/rofi/scripts/edit_config.sh")),
        desc="Search any config file and open in editor via rofi menu",
    ),
    Key(
        [mod],
        "p",
        lazy.spawn(os.path.expanduser("~/.config/rofi/scripts/get_pass.sh")),
        desc="Copy password to clipoard from KeepassXC",
    ),
    Key([mod], "f", lazy.spawn("nautilus")),
    Key([mod], "b", lazy.spawn("google-chrome-stable")),
    Key([mod, "control"], "x", lazy.spawn("xkill"), desc="Launch XKill"),
    Key([mod], "z", lazy.window.disable_floating(), desc="Unfloat current window"),
    Key([mod], "x", lazy.layout.flip(), desc="Flip Monadtall layout"),
    Key([mod], "c", lazy.spawn("code"), desc="Launch VSCode"),
    Key(
        [],
        "XF86PowerOff",
        lazy.spawn("arcolinux-logout"),
        desc="Launch arcolinux-logout with power button",
    ),
    # testing chords and modes
    KeyChord(
        [mod],
        "t",
        [
            # simple subcommand
            Key([], "t", lazy.spawn(terminal)),
            # window movement mode
            KeyChord(
                [],
                "w",
                [
                    Key([], "g", lazy.layout.grow()),
                    Key([], "s", lazy.layout.shrink()),
                ],
                mode="Window",
            ),
        ],
        mode="TEST CHORD",
    ),
]

# append keybindings for russian keyboard layout
lattoruskeys.append_ru_keys(keys)

# END OF KEYBINDINGS

# LAYOUTS
layouts = [
    # layout.Columns(border_focus_stack='#d75f5f'),
    layout.Columns(**layouts_theme),
    # layout.Max(),
    layout.Max(border_width=0, margin=0),
    layout.MonadTall(ratio=0.65, **layouts_theme),
    layout.Floating(**layouts_theme),
    # Try more layouts by unleashing below layouts.
    # layout.Stack(num_stacks=2, **layouts_theme),
    # layout.Bsp(**layouts_theme),
    # layout.Matrix(**layouts_theme),
    # layout.MonadWide(**layouts_theme),
    # layout.RatioTile(**layouts_theme),
    # layout.Tile(**layouts_theme),
    # layout.TreeTab(**layouts_theme),
    # layout.VerticalTile(**layouts_theme),
    # layout.Zoomy(**layouts_theme)
]

floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(wm_class="galculator"),
        Match(wm_class="keepassxc"),
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
        Match(title="MEGAsync"),  # mega.nz desktop client
        Match(title="win0"),  # jetbrains splash screen
    ],
    **layouts_theme,
)

# Drag floating layouts.
mouse = [
    Drag(
        [mod],
        "Button1",
        lazy.window.set_position_floating(),
        start=lazy.window.get_position(),
    ),
    Drag(
        [mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()
    ),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]
# END OF LAYOUTS

# GROUPS CONFIG
groups_config = [
    ("main", {"layout": "monadtall", "label": " Main"}),
    (
        "web",
        {
            "layout": "monadtall",
            "label": " Web",
            "matches": Match(wm_class=["firefox"]),
        },
    ),
    ("devel", {"layout": "columns", "label": " Devel"}),
    ("vm", {"layout": "max", "label": " VM", "matches": Match(wm_class=["vmplayer"])}),
    ("video", {"layout": "max", "label": " Video"}),
    ("misc", {"layout": "columns", "label": " Misc"}),
]
groups = [Group(name, **kwargs) for name, kwargs in groups_config]

for i, (name, kwargs) in enumerate(groups_config, 1):
    keys.append(Key([mod], str(i), lazy.group[name].toscreen()))
    keys.append(
        Key(
            [mod, "shift"],
            str(i),
            lazy.window.togroup(name, switch_group=switch_to_group_on_move),
        )
    )

# ADDING DROPDOWN TO GROUPS
groups.append(
    ScratchPad(
        "scratchpad",
        [
            DropDown("term", terminal),
            DropDown("qshell", terminal + " -e qtile shell"),
            # second dorpdown...
        ],
    ),
)

keys.append(Key([mod], "F11", lazy.group["scratchpad"].dropdown_toggle("term")))
keys.append(Key([mod], "F12", lazy.group["scratchpad"].dropdown_toggle("qshell")))
# END OF DORPDOWNS
# END OF GROUPS CONFIG

# BARS CONFIGURATION


def init_bar_widgets():
    """
    Return widgets set for panels
    """

    def Sep(visible=True):
        slv = SEPARATOR_LINEWIDTH
        if not visible:
            slv = 0
        return widget.Sep(
            linewidth=slv,
            padding=SEPARATOR_PADDING,
            foreground=THEME_COLORS["separator"],
        )

    return [
        Sep(visible=False),
        widget.TextBox(
            " ",
            fontsize=FONT_SIZE + 10,
            mouse_callbacks={"Button1": lambda: qtile.cmd_spawn(terminal)},
        ),
        Sep(visible=False),
        widget.GroupBox(
            fontsize=FONT_SIZE + 1,
            # font="Noto Sans Bold",
            margin_y=3,
            padding_y=5,
            padding_x=2,
            borderwidth=3,
            active=THEME_COLORS["active"],
            inactive=THEME_COLORS["inactive"],
            rounded=False,
            highlight_color=THEME_COLORS["hilight"],
            highlight_method="line",
            this_current_screen_border=THEME_COLORS["current_border"],
            # this_screen_border = colors [4],
            # other_current_screen_border = colors[6],
            # other_screen_border = colors[4],
        ),
        Sep(),
        widget.CurrentLayoutIcon(
            custom_icon_paths=[os.path.expanduser("~/.config/qtile/icons")],
            padding=0,
            scale=0.7,
        ),
        widget.CurrentLayout(
            # font = "Noto Sans Bold",
        ),
        Sep(),
        widget.Prompt(),
        widget.WindowName(),
        widget.Chord(
            chords_colors={
                "launch": ("#ff0000", "#ffffff"),
            },
            name_transform=lambda name: name.upper(),
        ),
        widget.Net(
            interface=WLAN_ADAPTER if WLAN_ADAPTER != "no wlan" else ETH_ADAPTER,
            format="{down} {up}",
            foreground="#68d945",
            use_bits=True,
        ),
        Sep(),
        widget.CPU(
            format=" {load_percent}%",
            foreground="#e08c0d",
            mouse_callbacks={"Button1": lambda: qtile.cmd_spawn(terminal + " -e htop")},
        ),
        Sep(),
        widget.Memory(
            # format= "{MemUsed: .0f}{mm}",
            format="{MemUsed: .0f}{mm}",
            foreground="#ff7de7",
            mouse_callbacks={"Button1": lambda: qtile.cmd_spawn(terminal + " -e htop")},
        ),
        Sep(),
        widget.DF(
            visible_on_warn=False,
            partition="/home",
            format=" {uf}{m}",
            foreground="#4f92ff",
            margin_x=0,
        ),
        Sep(),
        widget.TextBox(
            "",
            foreground="#f6ff7d",
        ),
        widget.ThermalSensor(
            foreground="#f6ff7d",
        ),
        Sep(),
        # add battery     widgets if battery is present in system
        *(
            (
                arcobattery.BatteryIcon(
                    padding=-16,
                    scale=0.5,
                    y_poss=8,
                    theme_path=os.path.expanduser(
                        "~/.config/qtile/icons/battery_icons_horiz"
                    ),
                    update_interval=5,
                    mouse_callbacks={
                        "Button1": lambda: qtile.widgets_map["batteryWBox"].cmd_toggle()
                    },
                ),
                widget.WidgetBox(
                    name="batteryWBox",
                    widgets=[
                        widget.Battery(
                            format="[{percent:2.0%} {hour:d}:{min:02d} {watt:.1f}W]",
                            # format=' [{percent:2.0%} {hour:d}:{min:02d} {watt:.1f}W]',
                            mouse_callbacks={
                                "Button1": lambda: qtile.cmd_spawn(
                                    terminal + " -e sudo powertop"
                                )
                            },
                        ),
                    ],
                    text_closed="",
                    text_open="",
                    close_button_location="right",
                ),
                Sep(),
            )
            if HAVE_BATTERY
            else ()
        ),
        # end of battery block
        widget.GenPollUrl(
            url="https://wttr.in/Yakutsk?m&format=3",
            json=False,
            parse=lambda x: "\n" + x.split(":")[1],
            fontsize=FONT_SIZE,
            padding=0,
            padding_top=30,
            mouse_callbacks={
                "Button1": lambda: qtile.cmd_spawn("firefox https://wttr.in/")
            },
        ),
        Sep(),
        widget.CheckUpdates(
            # update_interval = 1800,
            # font = 'FontAwesome',
            distro="Arch",
            display_format="  {updates}",
            no_update_string="",
            colour_have_updates="#f53b0c",
            colour_no_updates="#686e66",
            mouse_callbacks={
                "Button1": lambda: qtile.cmd_spawn(terminal + " -e sudo pacman -Syu")
            },
        ),
        Sep(),
        widget.Systray(
            # background='#000000',
            icon_size=24,
            padding=1,
        ),
        # widget.KeyboardLayout(
        #        font="Noto Sans Bold",
        #        configured_keyboards=["us","ru"],
        #        display_map={"us": 'En', "ru":"Ру"},
        #        options="grp:caps_toggle,grp_led:scroll",
        #        ),
        # widget.Sep(
        #        linewidth = SEPARATOR_LINEWIDTH,
        #        padding = SEPARATOR_PADDING,
        #        foreground = CLRS["separator"],
        #        ),
        Sep(),
        widget.Clock(
            # font="Noto Sans Bold",
            format=" %a, %d %B %H:%M",
        ),
        Sep(),
        widget.QuickExit(
            default_text="  ",
            fontsize=FONT_SIZE + 2,
            mouse_callbacks={"Button1": lambda: qtile.cmd_spawn("arcolinux-logout")},
        ),
    ]


# END OF BAR CONFIGURATION


# SCREENS CONFIGURATIONG
def screens_count():
    cmd = "xrandr | grep ' connected' | wc -l"
    return int(subprocess.getoutput(cmd))


def init_screens():
    # main screen
    screens_list = [Screen(top=bar.Bar(init_bar_widgets(), **bar_settings))]

    # secondary screens
    count = screens_count()
    if count > 1:
        for _ in range(count - 1):
            widgets = init_bar_widgets()
            del widgets[-5:-3]  # cut systray widget on secondary screens
            screens_list.append(Screen(top=bar.Bar(widgets, **bar_settings)))
    return screens_list


screens = init_screens()
# END OF SCREENS CONFIGURATION


# HOOKS
from libqtile.log_utils import logger


@hook.subscribe.current_screen_change
def hook_focus():
    logger.warning("current_screen_change()!")
    pass


@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser("~/.config/rusich/autostart.sh")
    subprocess.call([home])


# TODO: Better way is matching in group config


@hook.subscribe.client_new
def client_new(client):
    if client.name == "Oracle VM VirtualBox Менеджер":
        client.togroup("vm")
    # if client.name == 'Win10 [Работает] - Oracle VM VirtualBox'
    #    client.window.configure(stackmode=StackMode.Below)


# END OF HOOKS
