#!/bin/bash
layout=$(hyprctl devices -j | jq -r '.keyboards[] | .active_keymap' | sort | tail -n1 | cut -c1-2 | tr 'A-Z' 'a-z')

# if [ $layout = "en" ]; then
#     layout="us"
# fi

echo -n $layout
