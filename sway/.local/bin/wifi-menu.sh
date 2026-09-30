#!/bin/bash
# wifi-menu.sh — wofi Wi-Fi picker: list, connect, disconnect, toggle
# ponytail: cached list instant, rescan in background after close
# ponytail: single-instance, spam press exits silent
pidof -x "$(basename $0)" -o $$ >/dev/null 2>&1 && exit 0
ACTIVE=$(nmcli -t -f NAME connection show --active 2>/dev/null | head -1)
NETS=$(nmcli -t -f SSID,SIGNAL device wifi list --rescan no 2>/dev/null | awk -F: '!seen[$1]++ && $1 != "" {print $1}' | head -20)
PICK=$(printf 'Toggle Wi-Fi\nRefresh list\n%s' "$NETS" | wofi --dmenu --prompt "Wi-Fi (now: ${ACTIVE:-none})" --cache-file /dev/null)
[ -z "$PICK" ] && { nmcli device wifi rescan >/dev/null 2>&1 & exit 0; }
case "$PICK" in
  "Refresh list")
    nmcli device wifi rescan >/dev/null 2>&1
    sleep 3
    exec "$0" ;;
  "Toggle Wi-Fi")
    if [ "$(nmcli -t -f WIFI g)" = "enabled" ]; then nmcli radio wifi off; else nmcli radio wifi on; fi ;;
  *)
    SSID=$(echo "$PICK" | cut -d: -f1)
    if nmcli -t -f NAME connection show --active | grep -qx "$SSID"; then
      nmcli connection down "$SSID"
    elif nmcli -t -f NAME connection show | grep -qx "$SSID"; then
      nmcli connection up "$SSID"
    else
      PASS=$(wofi --dmenu --password --prompt "Password for $SSID" --cache-file /dev/null)
      [ -n "$PASS" ] && nmcli device wifi connect "$SSID" password "$PASS"
    fi ;;
esac
nmcli device wifi rescan >/dev/null 2>&1 &
