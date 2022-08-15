#!/usr/bin/env sh

alacritty -e sh -c 'sleep 0.01; echo $(($(ibox -c "Set brightness (%)" "?>") + 1)) | xargs -I {} lux -S {}%'

