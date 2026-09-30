#!/bin/bash
# shot.sh [full|region] — grim screenshot: save + copy to clipboard
# ponytail: grim native, no portal, no editor UI
DIR=/home/julry/Pictures/Screenshots
mkdir -p "$DIR"
FILE="$DIR/$(date +%F_%T).png"
if [ "$1" = "region" ]; then
  GEO=$(slurp 2>/dev/null) || exit 0
  grim -g "$GEO" "$FILE" || exit 0
else
  grim "$FILE" || exit 0
fi
wl-copy < "$FILE"
[ -x /usr/bin/notify-send ] && notify-send "Screenshot saved + copied" "$FILE"
