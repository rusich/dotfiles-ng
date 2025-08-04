#!/bin/bash

iDIR="$HOME/.config/dunst/icons"

UPDATES=$(checkupdates | wc -l)

if ! [ "${UPDATES}" -eq 0 ]; then
  notify-send -i "$iDIR/updates.png" "$UPDATES updates available"
  echo "$UPDATES" 󰏔
# else
#   notify-send -i "$iDIR/updates.png" "NO AVAILABLE UPDATES"
fi
