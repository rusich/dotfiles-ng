#!/usr/bin/env bash

function gen_configs_list() {
  # store full file path with spaces in for loop variable
  OIFS="$IFS"
  IFS=$'\n'

  for file in $({
    find ~/.dotfiles/ -type f
  }); do
    echo $file
  done
}

CONFIG_FILE=$(
  (gen_configs_list) | rofi -i -dmenu -p "Edit config file"
)

if [ -n "${CONFIG_FILE}" ]; then
  kitty -e nvim "${CONFIG_FILE}"
fi
