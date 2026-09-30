#!/bin/bash
# countdown.sh — 30s cancellable shutdown (from power menu)
swaynag -t warning -m 'Shutdown in 30 seconds.' -B 'Cancel shutdown' 'pkill -f "poweroff-countdown"' &
sleep 30 # poweroff-countdown
systemctl poweroff
