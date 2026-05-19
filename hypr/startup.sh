#!/bin/bash

# Fondo de pantalla
swaybg -i ~/.config/hypr/wallpapers/fondo.jpg &

# Barra
waybar &

# Portapapeles — historial persistente
wl-paste --watch cliphist store &

# Auto-lock e idle
swayidle -w \
    timeout 300  'hyprlock' \
    timeout 600  'hyprctl dispatch dpms off' \
    resume       'hyprctl dispatch dpms on' \
    before-sleep 'hyprlock' &

# Workspace 1 — Terminal principal
sleep 1
alacritty --title homebase &

# Workspace 2 — Browser (investigación / OSINT)
(sleep 2 && firefox) &

# Workspace 3 — Editor
(sleep 3 && kitty --title nvim-ws -e nvim) &

# Workspace 4 — Monitor del sistema
(sleep 3 && kitty --title btop-ws -e btop) &

# Workspace 5 — VMs / Lab
(sleep 4 && virt-manager) &
