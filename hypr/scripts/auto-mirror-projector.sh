#!/bin/bash
# Daemon: escucha eventos de Hyprland y aplica espejo automático
# en cualquier monitor externo (que no sea eDP-1).
# - monitoradded:    aplica el modo actual (espejo por defecto)
# - configreloaded:  reaplica el modo (un reload/guardar config borra los "keyword monitor")
# - monitorremoved:  vuelve a espejo por defecto y reactiva hypridle

. "$(dirname "$0")/proyector-lib.sh"

# Ignora eventos provocados por nuestros propios cambios (evita bucles)
recent_change() {
    local last
    last=$(cat "$STAMP_FILE" 2>/dev/null || echo 0)
    [ $(( $(date +%s) - last )) -lt 3 ]
}

get_socket() {
    local runtime="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
    if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
        echo "$runtime/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
    else
        find "$runtime/hypr" -name ".socket2.sock" 2>/dev/null | head -1
    fi
}

rm -f "$MODE_FILE" "$STAMP_FILE"

# Monitor ya conectado al iniciar sesión
sleep 2
EXT=$(get_external)
[ -n "$EXT" ] && apply_mode "$EXT" mirror

while true; do
    SOCK=$(get_socket)
    if [ ! -S "$SOCK" ]; then
        sleep 2
        continue
    fi
    socat -u "UNIX-CONNECT:$SOCK" - 2>/dev/null | while IFS= read -r line; do
        ev="${line%%>>*}"
        data="${line#*>>}"
        case "$ev" in
            monitoradded)
                [ "$data" = "$INTERNAL" ] && continue
                recent_change && continue
                ( sleep 1; apply_mode "$data" "$(get_mode)" ) &
                ;;
            configreloaded)
                recent_change && continue
                ( sleep 0.5; EXT=$(get_external); [ -n "$EXT" ] && apply_mode "$EXT" "$(get_mode)" silent ) &
                ;;
            monitorremoved)
                [ "$data" = "$INTERNAL" ] && continue
                recent_change && continue
                [ -z "$(get_external)" ] && { rm -f "$MODE_FILE"; idle_resume; }
                ;;
        esac
    done
    sleep 2
done
