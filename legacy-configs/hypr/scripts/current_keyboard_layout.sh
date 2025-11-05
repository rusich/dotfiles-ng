#!/usr/bin/env bash
hyprctl devices -j | jq -r '.keyboards[] | .active_keymap' | sort | tail -n1 | cut -c1-2 | tr 'A-Z' 'a-z'
