#!/usr/bin/env python

import json
import os
from subprocess import PIPE, Popen

data = {}

#Popen process with cli arugment 


process = Popen(["checkupdates", "--nocolor"], stdout=PIPE)
(output, err) = process.communicate()
# exit_code = process.wait()
num_updates = len(output.splitlines())


if num_updates > 0:
    data["text"] = "󰮯<sub><small> </small>" + str(num_updates) + "</sub>"
    # data["text"] = "󰏔 "

    tooltip = str(output).replace("\\n", "\n").replace("b'", "").replace("'", "")
    data["tooltip"] = f"<tt><b><u>{num_updates} updates available:</u></b>\n<small>" + tooltip + "</small></tt>"

    notify_icon = os.path.expanduser("~/.config/dunst/icons/updates.png")
    notify_cmd = (
        f'notify-send -i "{notify_icon}" Pacman "{num_updates} updates available"'
    )
    os.system(notify_cmd)

print(json.dumps(data))
