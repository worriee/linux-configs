#!/bin/bash
# countdown.sh — 30s cancellable shutdown (from power menu)
# ponytail: named sleep so Cancel pkill matches a real process
swaynag -t warning -m 'Shutdown in 30 seconds.' -B 'Cancel shutdown' 'pkill -f "poweroff-countdown"' &
bash -c 'exec -a poweroff-countdown sleep 30' & wait $! || exit 0
systemctl poweroff
