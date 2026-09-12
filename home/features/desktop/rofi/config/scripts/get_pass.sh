#!/usr/bin/env bash

DATABASE=$HOME"/Nextcloud/Configs/Passwords.kdbx"

PASSFOR=$(secret-tool lookup name keepass | keepassxc-cli search -q ${DATABASE} '' | rofi -dmenu -i -p "Select password")

if [ -n "${PASSFOR}" ]; then
  TIMEOUT="20"
  # notify-send "PASSFOR: ${PASSFOR}"
  secret-tool lookup name keepass | keepassxc-cli clip -q "$DATABASE" "$PASSFOR" $TIMEOUT &
  notify-send -u low -i keepassxc "KeepassXC" "Password for ${PASSFOR} copied to clipboard for ${TIMEOUT} seconds"
fi
