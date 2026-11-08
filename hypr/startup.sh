#!/bin/bash

# Fondo de pantalla
swaybg -i ~/.config/hypr/wallpapers/fondo.jpg -m fill &

# Barra
# Se reinicia sola si crashea (bug de mpris/playerctl en waybar 0.15)
(while true; do waybar; sleep 1; done) &

# Portapapeles — historial persistente
wl-paste --watch cliphist store &

# Auto-lock e idle
hypridle &  # config en ~/.config/hypr/hypridle.conf

# --- Apps de inicio ---
# El workspace se asigna SOLO al lanzarlas aquí (exec rule de un solo uso).
# Si después las abres a mano, se abren en el workspace donde estés.

# Workspace 1 — Browser
sleep 1
hyprctl dispatch 'hl.dsp.exec_cmd("zen-browser", { workspace = "1 silent" })'

# Workspace 2 — Música
(sleep 2 && hyprctl dispatch 'hl.dsp.exec_cmd("youtube-music", { workspace = "2 silent" })') &

# Workspace 3 — Discord
# Discord hace fork: la regla de exec no le aplica, se mueve al aparecer su ventana
(sleep 3 && hyprctl dispatch 'hl.dsp.exec_cmd("discord")'
 for _ in $(seq 60); do
     hyprctl clients -j | jq -e '.[] | select(.class == "discord")' >/dev/null && break
     sleep 0.5
 done
 hyprctl dispatch 'hl.dsp.window.move({ window = "class:^(discord)$", workspace = 3, follow = false })') &

# Workspace 4 — VS Code
(sleep 3 && hyprctl dispatch 'hl.dsp.exec_cmd("code", { workspace = "4 silent" })') &

# Workspace 5 — VMs / Lab
(sleep 4 && hyprctl dispatch 'hl.dsp.exec_cmd("virt-manager", { workspace = "5 silent" })') &

# Workspace 6 — NVIM
(sleep 4 && hyprctl dispatch 'hl.dsp.exec_cmd("kitty --title nvim-ws -e nvim", { workspace = "6 silent" })') &
