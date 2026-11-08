#!/bin/bash
# Keybind manual (Super+Alt+O): restaura modo extendido en monitor externo

. "$(dirname "$0")/proyector-lib.sh"

EXT=$(get_external)
if [ -z "$EXT" ]; then
    notify-send "Proyector" "No hay monitor externo conectado" -u normal 2>/dev/null
    exit 1
fi

apply_mode "$EXT" extend
