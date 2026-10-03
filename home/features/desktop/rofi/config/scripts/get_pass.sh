#!/usr/bin/env bash

DATABASE=$HOME"/Nextcloud/Configs/Passwords.kdbx"
DBPASS=$HOME"/.config/sops-nix/secrets/keepass/database-password"

PASSFOR=$(cat "$DBPASS" | keepassxc-cli search -q ${DATABASE} '' | rofi -dmenu -i -p "Select password")

if [ -n "${PASSFOR}" ]; then
  TIMEOUT="20"
  # notify-send "PASSFOR: ${PASSFOR}"
  cat "$DBPASS" | keepassxc-cli clip -q "$DATABASE" "$PASSFOR" $TIMEOUT &
  notify-send -u low -i keepassxc "KeepassXC" "Password for ${PASSFOR} copied to clipboard for ${TIMEOUT} seconds"
fi
