import copy
import os
import libqtile
from libqtile.config import Key, KeyChord
from libqtile.lazy import lazy

#QWERTY Lat to QWERTY Rus map
LatRusMap = {
    '~': 'Cyrillic_IO',
    '`': 'Cyrillic_io',
    'Q': 'Cyrillic_SHORTI',
    'q': 'Cyrillic_shorti',
    'W': 'Cyrillic_TSE',
    'w': 'Cyrillic_tse',
    'E': 'Cyrillic_U',
    'e': 'Cyrillic_u',
    'R': 'Cyrillic_KA',
    'r': 'Cyrillic_ka',
    'T': 'Cyrillic_IE',
    't': 'Cyrillic_ie',
    #'T': 'Cyrillic_JE',
    #'t': 'Cyrillic_je',
    'Y': 'Cyrillic_EN',
    'y': 'Cyrillic_en',
    'U': 'Cyrillic_GHE',
    'u': 'Cyrillic_ghe',
    'I': 'Cyrillic_SHA',
    'i': 'Cyrillic_sha',
    'O': 'Cyrillic_SHCHA',
    'o': 'Cyrillic_shcha',
    'P': 'Cyrillic_ZE',
    'p': 'Cyrillic_ze',
    '{': 'Cyrillic_HA',
    '[': 'Cyrillic_ha',
    '}': 'Cyrillic_HARDSIGN',
    ']': 'Cyrillic_hardsign',
    'A': 'Cyrillic_EF',
    'a': 'Cyrillic_ef',
    'S': 'Cyrillic_YERU',
    's': 'Cyrillic_yeru',
    'D': 'Cyrillic_VE',
    'd': 'Cyrillic_ve',
    'F': 'Cyrillic_A',
    'f': 'Cyrillic_a',
    'G': 'Cyrillic_PE',
    'g': 'Cyrillic_pe',
    'H': 'Cyrillic_ER',
    'h': 'Cyrillic_er',
    'J': 'Cyrillic_O',
    'j': 'Cyrillic_o',
    'K': 'Cyrillic_EL',
    'k': 'Cyrillic_el',
    'L': 'Cyrillic_DE',
    'l': 'Cyrillic_de',
    ':': 'Cyrillic_ZHE',
    ';': 'Cyrillic_zhe',
    '"': 'Cyrillic_E',
    '\'': 'Cyrillic_e',
    'Z': 'Cyrillic_YA',
    'z': 'Cyrillic_ya',
    'X': 'Cyrillic_CHE',
    'x': 'Cyrillic_che',
    'C': 'Cyrillic_ES',
    'c': 'Cyrillic_es',
    'V': 'Cyrillic_EM',
    'v': 'Cyrillic_em',
    'B': 'Cyrillic_I',
    'b': 'Cyrillic_i',
    'N': 'Cyrillic_TE',
    'n': 'Cyrillic_te',
    'M': 'Cyrillic_SOFTSIGN',
    'm': 'Cyrillic_softsign',
    '<': 'Cyrillic_BE',
    '.': 'Cyrillic_be',
    '>': 'Cyrillic_YU',
    '?': 'Cyrillic_yu',
    #'I': 'Cyrillic_SHHA',
    #'i': 'Cyrillic_shha',
    #'O': 'Cyrillic_SCHWA',
    #'o': 'Cyrillic_schwa',
    #'':'Cyrillic_GHE_bar',
    #'':'Cyrillic_ghe_bar',
    #'':'Cyrillic_ZHE_descender',
    #'':'Cyrillic_zhe_descender',
    #'':'Cyrillic_KA_descender',
    #'':'Cyrillic_ka_descender',
    #'':'Cyrillic_KA_vertstroke',
    #'':'Cyrillic_ka_vertstroke',
    #'':'Cyrillic_EN_descender',
    #'':'Cyrillic_en_descender',
    #'':'Cyrillic_U_straight',
    #'':'Cyrillic_u_straight',
    #'':'Cyrillic_U_straight_bar',
    #'':'Cyrillic_u_straight_bar',
    #'':'Cyrillic_HA_descender',
    #'':'Cyrillic_ha_descender',
    #'':'Cyrillic_CHE_descender',
    #'':'Cyrillic_che_descender',
    #'':'Cyrillic_CHE_vertstroke',
    #'':'Cyrillic_che_vertstroke',
    #'':'Cyrillic_O_bar',
    #'':'Cyrillic_o_bar',
    #'':'Cyrillic_U_macron',
    #'':'Cyrillic_u_macron',
    #'': 'Cyrillic_I_macron',
    #'': 'Cyrillic_i_macron',
    #'': 'Cyrillic_lje',
    #'': 'Cyrillic_nje',
    #'': 'Cyrillic_dzhe',
    #'': 'Cyrillic_LJE',
    #'': 'Cyrillic_NJE',
    #'': 'Cyrillic_DZHE',
}


def append_ru_keys(en_keys):
    rus_keys = []

    for k in en_keys:
        if isinstance(k,  libqtile.config.Key):
            if k.key in LatRusMap.keys():
                rus_key = copy.deepcopy(k)
                rus_key.key = LatRusMap[k.key]
                rus_keys.append(rus_key)
        elif isinstance(k, libqtile.config.KeyChord):
            rus_keys.append(_translate_keychord(k))

    en_keys.extend(rus_keys)


def _translate_keychord(keychord):
    rus_kc = copy.deepcopy(keychord)
    if rus_kc.key in LatRusMap.keys():
        rus_kc.key = LatRusMap[rus_kc.key]
        for i, _ in enumerate(rus_kc.submappings):
            if isinstance(rus_kc.submappings[i], libqtile.config.Key):
                if rus_kc.submappings[i].key in LatRusMap.keys():
                    rus_kc.submappings[i].key = LatRusMap[rus_kc.submappings[i].key]
            elif isinstance(rus_kc.submappings[i], libqtile.config.KeyChord):
                rus_kc.submappings[i] = _translate_keychord(
                    rus_kc.submappings[i])
    return rus_kc


#TESTING
if __name__ == '__main__':
    print('in main')
    # KEY BINDINGS
    mod = "mod4"
    keys = [
        # Launch terminal
        Key([mod], "Return", lazy.spawn('alacritty'), desc="Launch terminal"),
        #Change keyboard layout

        # Switch between windows
        Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
        Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
        Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
        Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
        Key([mod], "space", lazy.layout.next(),
            desc="Move window focus to other window"),

        # Move windows between left/right columns or move up/down in current stack.
        # Moving out of range in Columns layout will create new column.
        Key([mod, "shift"], "h", lazy.layout.shuffle_left(),
            desc="Move window to the left"),
        Key([mod, "shift"], "l", lazy.layout.shuffle_right(),
            desc="Move window to the right"),
        Key([mod, "shift"], "j", lazy.layout.shuffle_down(),
            desc="Move window down"),
        Key([mod, "shift"], "k", lazy.layout.shuffle_up(),
            desc="Move window up"),

        # Grow windows. If current window is on the edge of screen and direction
        # will be to screen edge - window would shrink.
        Key([mod, "control"], "h", lazy.layout.grow_left(),
            desc="Grow window to the left"),
        Key([mod, "control"], "l", lazy.layout.grow_right(),
            desc="Grow window to the right"),
        Key([mod, "control"], "j", lazy.layout.grow_down(),
            desc="Grow window down"),
        Key([mod, "control"], "k", lazy.layout.grow_up(),
            desc="Grow window up"),
        Key([mod], "n", lazy.layout.normalize(),
            desc="Reset all window sizes"),

        # Toggle between split and unsplit sides of stack.
        # Split = all windows displayed
        # Unsplit = 1 window displayed, like Max layout, but still with
        # multiple stack panes
        Key([mod, "shift"], "Return", lazy.layout.toggle_split(),
            desc="Toggle between split and unsplit sides of stack"),

        # Toggle between different layouts as defined below
        Key([mod], "Tab", lazy.next_layout(), desc="Toggle next layout"),
        Key([mod, "shift"], "Tab", lazy.prev_layout(),
            desc="Toggle prev layout"),
        Key([mod], "w", lazy.window.kill(), desc="Kill focused window"),
        Key([mod, "control"], "r", lazy.restart(), desc="Restart Qtile"),
        Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
        Key([mod], "r", lazy.spawncmd(),
            desc="Spawn a command using a prompt widget"),
        Key([mod], "m", lazy.spawn("rofi -show"), desc="Spawn a rofi menu"),
        Key([mod, "shift"], "m", lazy.spawn("rofi -show drun -run-shell-command '{terminal} -e {cmd}'"),
            desc="Spawn a rofi menu, then run selected program in a terminal window"),
        Key([mod], "d", lazy.spawn("dmenu_run"),
            desc="Spawn a command using a prompt widget"),
        Key([mod], "c", lazy.spawn(os.path.expanduser("~/.config/rofi/scripts/edit_config.sh")),
            desc="Search any config file and open in editor via rofi menu"),
        Key([mod], "f", lazy.spawn("firefox")),

        Key([], "XF86PowerOff", lazy.spawn("arcolinux-logout"),
                desc="Launch arcolinux-logout with power button"),

        #testing chords and modes
        KeyChord([mod], "t", [
            # simple subcommand
            Key([], "t", lazy.spawn('alacritty')),
            # window movement mode
            KeyChord([], "w", [
                Key([], "g", lazy.layout.grow()),
                Key([], "s", lazy.layout.shrink()),
            ], mode="Window")
        ]),
    ]
    # END OF KEYBINDINGS

    print(len(keys))
    append_ru_keys(keys)
    print(len(keys))
