#!/bin/bash
# launcher.sh — wofi app launcher, single-instance
# ponytail: pgrep scoped to drun, menus unaffected
pgrep -f "wofi --show drun" >/dev/null 2>&1 && exit 0
exec wofi --show drun
