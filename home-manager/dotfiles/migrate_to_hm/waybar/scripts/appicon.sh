#!/bin/bash
activeclass=$(hyprctl activewindow | awk '/class: / {print $2}')
if [[ -z $activeclass ]] 
then
   # spotify is dead, we should die too.
   exit
fi
# find ~/Nextcloud/Configs/Icons/Clarity/scalable/apps/ -type f -name "*$activeclass*" -print -quit
find /usr/share/icons/ -type f -name "*$activeclass*" -print -quit
