#!/bin/bash
# notif-center.sh — mako notification history + quiet toggle in wofi (Super+N)
# ponytail: single makoctl mode call, stdlib python only
# ponytail: single-instance, spam press exits silent
pidof -x "$(basename $0)" -o $$ >/dev/null 2>&1 && exit 0
MODE=$(makoctl mode 2>/dev/null)
case "$MODE" in
  *do-not-disturb*) DND="Turn Do-Not-Disturb OFF" ;;
  *) DND="Turn Do-Not-Disturb ON" ;;
esac
HIST=$(makoctl list -j 2>/dev/null | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
except Exception:
    data = []
for n in data:
    app = n.get('app-name', '?')
    summary = str(n.get('summary', '')).replace(chr(10), ' ')
    print('%s | %s' % (app, summary))
")
[ -z "$HIST" ] && HIST="(no notifications)"
PICK=$(printf '%s\nClear all notifications\n---\n%s' "$DND" "$HIST" | wofi --dmenu --prompt Notifications --cache-file /dev/null)
case "$PICK" in
  "Turn Do-Not-Disturb"*) /home/julry/.local/bin/mako-bell.sh toggle ;;
  "Clear all"*) makoctl dismiss -a ;;
esac
