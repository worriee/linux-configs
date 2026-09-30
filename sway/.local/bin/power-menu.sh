#!/bin/bash
# power-menu.sh — wofi power menu (panel power icon)
# ponytail: single-instance, spam press exits silent
pidof -x "$(basename $0)" -o $$ >/dev/null 2>&1 && exit 0
PICK=$(printf 'Lock\nSuspend\nLogout\nReboot\nShutdown' | wofi --dmenu --prompt Power --cache-file /dev/null)
case "$PICK" in
  Lock) swaylock -f -c 000000 ;;
  Suspend) systemctl suspend ;;
  Logout) swaymsg exit ;;
  Reboot) systemctl reboot ;;
  Shutdown) /home/julry/.local/bin/countdown.sh ;;
esac
