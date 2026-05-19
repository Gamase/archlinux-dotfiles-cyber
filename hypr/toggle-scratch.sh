#!/bin/bash
# Abre o cierra el scratchpad. Si está vacío, lanza una terminal primero.
windows=$(hyprctl workspaces | awk '/special:scratch/{found=1} found && /windows:/{print $2; exit}')

if [ -z "$windows" ] || [ "$windows" = "0" ]; then
    alacritty --class scratchpad &
    sleep 0.3
fi

hyprctl dispatch togglespecialworkspace scratch
