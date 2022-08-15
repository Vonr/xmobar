#!/usr/bin/env sh

alacritty -e sh -c 'sleep 0.01; ibox -c "Set volume (%)" "?>" | xargs -I {} pactl set-sink-volume @DEFAULT_SINK@ {}%'

