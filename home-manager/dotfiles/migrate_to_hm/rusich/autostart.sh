#!/bin/sh
picom &
# /usr/lib/xfce4/notifyd/xfce4-notifyd &
dunst &
xfce4-power-manager --daemon
nm-applet &
# volumeicon &
pasystray &
nitrogen --restore &
#QT_SCALE_FACTOR=1.0 megasync&
nextcloud &
QT_SCALE_FACTOR=1 lxqt-policykit-agent &
keepassxc &
#/usr/bin/ibus-daemon --xim --replace --daemonize --panel=/usr/lib/ibus/ibus-ui-gtk3
setxkbmap -layout us,ru -option grp:win_space_toggle &
#~/Nextcloud/AppImages/Joplin.AppImage &
blueman-applet &
