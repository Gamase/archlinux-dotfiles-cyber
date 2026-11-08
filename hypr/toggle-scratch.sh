#!/bin/bash
# Abre o cierra el scratchpad. Si está vacío, lanza una terminal primero.
windows=$(hyprctl workspaces -j | jq -r '.[] | select(.name == "special:scratch") | .windows')

if [ -z "$windows" ] || [ "$windows" = "0" ]; then
    alacritty --class scratchpad &
    sleep 0.3
fi

hyprctl dispatch 'hl.dsp.workspace.toggle_special("scratch")'
