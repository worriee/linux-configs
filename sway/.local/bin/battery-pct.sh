#!/bin/bash
# battery-pct.sh — sysfs-direct battery readout (BAT1), immune to waybar module bugs
CAP=$(cat /sys/class/power_supply/BAT1/capacity 2>/dev/null || echo 0)
STATUS=$(cat /sys/class/power_supply/BAT1/status 2>/dev/null || echo Unknown)
if [ "$CAP" -ge 90 ]; then ICON=$'\uf240'
elif [ "$CAP" -ge 65 ]; then ICON=$'\uf241'
elif [ "$CAP" -ge 40 ]; then ICON=$'\uf242'
elif [ "$CAP" -ge 15 ]; then ICON=$'\uf243'
else ICON=$'\uf244'; fi
CLASS=ok
[ "$CAP" -lt 30 ] && CLASS=warning
[ "$CAP" -lt 15 ] && CLASS=critical
printf '{"text":"%s %s%%","class":"%s","tooltip":"%s%% %s"}\n' "$ICON" "$CAP" "$CLASS" "$CAP" "$STATUS"
