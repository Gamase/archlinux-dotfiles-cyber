#!/bin/bash
# Menú de volumen para Waybar (rofi).
# - Silenciar / niveles rápidos / valor exacto
# - Cambiar la salida de audio (mueve lo que esté sonando al nuevo dispositivo)
# - Silenciar el micrófono, abrir el mezclador

THEME=~/.config/rofi/waybar.rasi
SIGNAL=1   # debe coincidir con "signal" de custom/volume en la config de waybar

INPUT_STYLE='window { width: 380px; }
inputbar { enabled: true; padding: 8px 12px; border-radius: 8px; background-color: rgba(0, 30, 80, 60%); children: [prompt, entry]; spacing: 8px; }
prompt { background-color: transparent; }
entry { background-color: transparent; text-color: #66bbff; placeholder-color: #33557a; placeholder: "0-100"; }
listview { enabled: false; }
textbox { text-color: #66bbff; background-color: transparent; }'

rofi_menu()  { rofi -dmenu -i -p "$1" -theme "$THEME" -theme-str 'window { width: 380px; } listview { lines: 10; }'; }
rofi_input() { rofi -dmenu -p "$1" -mesg "$2" -theme "$THEME" -theme-str "$INPUT_STYLE" < /dev/null; }
refresh()    { pkill -RTMIN+$SIGNAL waybar; }

notify_volume() {
    local vol mute icon
    vol=$(pamixer --get-volume)
    mute=$(pamixer --get-mute)
    if [ "$mute" = "true" ]; then icon=audio-volume-muted; vol=0
    elif [ "$vol" -lt 33 ]; then icon=audio-volume-low
    elif [ "$vol" -lt 66 ]; then icon=audio-volume-medium
    else icon=audio-volume-high; fi
    notify-send -a Volumen -i "$icon" -h string:x-dunst-stack-tag:volume \
        -h "int:value:$vol" "Volumen" "$([ "$mute" = "true" ] && echo "Silenciado" || echo "$vol%")"
}

# Cambia la salida por defecto y mueve las apps que estén sonando
set_sink() {
    local sink=$1 input
    pactl set-default-sink "$sink" || return
    for input in $(pactl list short sink-inputs | awk '{print $1}'); do
        pactl move-sink-input "$input" "$sink" 2>/dev/null
    done
}

# --- Construir el menú ---
VOL=$(pamixer --get-volume)
MUTED=$(pamixer --get-mute)
MIC_MUTED=$(pactl get-source-mute @DEFAULT_SOURCE@ 2>/dev/null | awk '{print $2}')
DEFAULT_SINK=$(pactl get-default-sink)

if [ "$MUTED" = "true" ]; then
    opts="󰕾  Activar sonido"$'\n'
    header="󰝟  Volumen: silenciado"
else
    opts="󰝟  Silenciar"$'\n'
    header="󰕾  Volumen: $VOL%"
fi
opts+=$'󰕿  25%\n󰖀  50%\n󰕾  75%\n󰕾  100%\n󰏫  Otro valor…\n'

# Salidas de audio (los nombres vienen del dispositivo: se tratan como datos, sin echo -e)
declare -A SINKS
while IFS=$'\t' read -r name desc; do
    [ -z "$name" ] && continue
    if [ "$name" = "$DEFAULT_SINK" ]; then
        label="󰓃  $desc  (actual)"
    else
        label="󰓃  $desc"
    fi
    SINKS["$label"]=$name
    opts+="$label"$'\n'
done < <(pactl -f json list sinks 2>/dev/null | jq -r '.[] | [.name, .description] | @tsv')

if [ "$MIC_MUTED" = "yes" ]; then
    opts+="󰍬  Activar micrófono"$'\n'
else
    opts+="󰍭  Silenciar micrófono"$'\n'
fi
opts+="󰒓  Mezclador (pavucontrol)"

choice=$(printf '%s\n' "$opts" | rofi_menu "$header")

# Las salidas de audio van primero: su nombre podría parecerse a otra opción del menú
if [ -n "$choice" ] && [ -n "${SINKS["$choice"]}" ]; then
    set_sink "${SINKS["$choice"]}"
    notify-send -a Volumen -i audio-card -h string:x-dunst-stack-tag:volume "Salida de audio" "${choice#*  }"
    refresh
    exit 0
fi

case "$choice" in
    "") exit 0 ;;
    *"Silenciar micrófono"|*"Activar micrófono")
        pactl set-source-mute @DEFAULT_SOURCE@ toggle
        if [ "$(pactl get-source-mute @DEFAULT_SOURCE@ | awk '{print $2}')" = "yes" ]; then
            notify-send -a Volumen -i microphone-sensitivity-muted -h string:x-dunst-stack-tag:mic "Micrófono" "Silenciado"
        else
            notify-send -a Volumen -i microphone-sensitivity-high -h string:x-dunst-stack-tag:mic "Micrófono" "Activado"
        fi
        ;;
    *"Silenciar"|*"Activar sonido")
        pamixer -t; notify_volume ;;
    *"Otro valor…")
        val=$(rofi_input "Volumen:" "Actual: $VOL%") || exit 0
        val=${val%\%}
        if [[ "$val" =~ ^[0-9]+$ ]] && [ "$val" -le 100 ]; then
            pamixer -u --set-volume "$val"; notify_volume
        else
            notify-send -a Volumen -u normal "Valor inválido" "Escribe un número de 0 a 100"
        fi
        ;;
    *"Mezclador"*)
        pkill -x pavucontrol || pavucontrol -t 1 & ;;
    *%)
        val=${choice##* }; val=${val%\%}
        pamixer -u --set-volume "$val"; notify_volume ;;
esac
refresh
