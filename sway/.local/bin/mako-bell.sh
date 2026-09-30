#!/bin/bash
# mako-bell.sh [toggle] — waybar bell module.
# No arg: print current state as JSON. Arg "toggle": flip quiet mode first.
if [ "$1" = "toggle" ]; then
  if makoctl mode | grep -q "do-not-disturb"; then
    makoctl set-mode default
  else
    makoctl set-mode do-not-disturb
  fi
fi
BELL_OFF=$'\uf1f6'
BELL_ON=$'\uf0f3'
if makoctl mode | grep -q "do-not-disturb"; then
  printf '{"text":"%s","class":"dnd"}\n' "$BELL_OFF"
else
  printf '{"text":"%s","class":"ok"}\n' "$BELL_ON"
fi
