#!/bin/bash
# bluetooth-menu.sh — wofi BT picker: toggle, connect/disconnect paired
# ponytail: bluetoothctl text parse, switch to bluetuith when pairing UX hurts
# ponytail: single-instance, spam press exits silent
pidof -x "$(basename $0)" -o $$ >/dev/null 2>&1 && exit 0
PWR=$(bluetoothctl show 2>/dev/null | awk '/Powered:/{print $2}')
DEVS=$(bluetoothctl devices 2>/dev/null | awk '{ $1=$2=""; sub(/^  /, ""); print }' | grep -v '^$')
PICK=$(printf 'Toggle Bluetooth\nScan for devices\n%s' "$DEVS" | wofi --dmenu --prompt "BT (${PWR:-off})" --cache-file /dev/null)
[ -z "$PICK" ] && exit 0
[ "$PICK" = "Scan for devices" ] && { bluetoothctl --timeout 8 scan on >/dev/null 2>&1; exec "$0"; }
[ "$PICK" = "Toggle Bluetooth" ] && { [ "$PWR" = "yes" ] && bluetoothctl power off || bluetoothctl power on; exit 0; }
MAC=$(bluetoothctl devices 2>/dev/null | grep -F " $PICK" | awk '{print $2}' | head -1)
[ -z "$MAC" ] && exit 0
if bluetoothctl info "$MAC" 2>/dev/null | grep -q "Connected: yes"; then
  bluetoothctl disconnect "$MAC"
else
  bluetoothctl trust "$MAC" >/dev/null 2>&1
  bluetoothctl connect "$MAC"
fi
