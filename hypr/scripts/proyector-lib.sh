#!/bin/bash
# Funciones compartidas por mirror-manual.sh, extend-manual.sh y auto-mirror-projector.sh

INTERNAL="eDP-1"
STATE_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
MODE_FILE="$STATE_DIR/proyector-mode"     # mirror | extend
STAMP_FILE="$STATE_DIR/proyector-stamp"   # epoch del último cambio aplicado

# Primer monitor externo, incluyendo los que están en espejo
# (`hyprctl monitors` sin "all" NO lista los monitores en espejo)
get_external() {
    hyprctl monitors all -j 2>/dev/null \
        | jq -r --arg i "$INTERNAL" '[.[] | select(.name != $i)][0].name // empty'
}

get_mode() {
    cat "$MODE_FILE" 2>/dev/null || echo mirror
}

# Hypridle bloquea a los 5 min: se pausa mientras se presenta
idle_pause() {
    pkill -x hypridle 2>/dev/null || true
}

idle_resume() {
    pgrep -x hypridle >/dev/null || hyprctl dispatch 'hl.dsp.exec_cmd("hypridle")' >/dev/null
}

# apply_mode <monitor> <mirror|extend> [silent]
apply_mode() {
    local ext="$1" mode="$2"
    # $ext se inserta en código Lua (hyprctl eval): solo nombres de conector válidos (HDMI-A-1, DP-2…)
    [[ "$ext" =~ ^[A-Za-z0-9-]+$ ]] || return 1
    date +%s > "$STAMP_FILE"
    echo "$mode" > "$MODE_FILE"
    if [ "$mode" = "mirror" ]; then
        hyprctl eval "hl.monitor({ output = \"$ext\", mode = \"preferred\", position = \"auto\", scale = 1, mirror = \"$INTERNAL\" })" >/dev/null
        idle_pause
        [ -z "$3" ] && notify-send "Proyector" "Espejo en $ext (bloqueo automático pausado)" -t 4000 2>/dev/null
    else
        hyprctl eval "hl.monitor({ output = \"$ext\", mode = \"preferred\", position = \"auto\", scale = 1, mirror = \"\" })" >/dev/null
        idle_resume
        [ -z "$3" ] && notify-send "Proyector" "Modo extendido en $ext" -t 3000 2>/dev/null
    fi
    return 0
}
