#!/usr/bin/env bash

function get_files_list()
{
	for f in  `{ find ~ -type d -path '*/\.*' -prune -o -not -iname '.*' -type f; }`; do

		echo $f
	done
}

FILE=$( ( get_files_list)  | rofi -i -dmenu -p "Open File")

if [ -n "${FILE}" ]
then
    #alacritty -e "vim" "${FILE}"
    xdg-open "${FILE}"
fi
