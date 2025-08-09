#!/usr/bin/env bash

function gen_configs_list() {
  # store full file path with spaces in for loop variable
  OIFS="$IFS"
  IFS=$'\n'

  for file in $({
    find . -maxdepth 1 -type f &
    find ~/.config -type f
  }); do
    echo $file
  done
}

CONFIG_FILE=$(
  (gen_configs_list) | grep -Fv \
    -e ".config/libreoffice" \
    -e ".config/YandexBrowser" \
    -e ".config/yandex-browser" |
    rofi -i -dmenu -p "Edit config file"
)

if [ -n "${CONFIG_FILE}" ]; then
  GIT_DIR="$HOME/.cfg" GIT_WORK_TREE="$HOME" kitty -e nvim "${CONFIG_FILE}"
fi
