#!/bin/bash
# Menú de brillo para Waybar (rofi): niveles rápidos o valor exacto

THEME=~/.config/rofi/waybar.rasi
SIGNAL=2   # debe coincidir con "signal" de custom/brightness en la config de waybar
MIN=5      # nunca bajar de aquí: con 0% la pantalla queda negra

INPUT_STYLE='window { width: 380px; }
inputbar { enabled: true; padding: 8px 12px; border-radius: 8px; background-color: rgba(0, 30, 80, 60%); children: [prompt, entry]; spacing: 8px; }
prompt { background-color: transparent; }
entry { background-color: transparent; text-color: #66bbff; placeholder-color: #33557a; placeholder: "5-100"; }
listview { enabled: false; }
textbox { text-color: #66bbff; background-color: transparent; }'

rofi_menu()  { rofi -dmenu -i -p "$1" -theme "$THEME" -theme-str 'window { width: 380px; } listview { lines: 6; }'; }
rofi_input() { rofi -dmenu -p "$1" -mesg "$2" -theme "$THEME" -theme-str "$INPUT_STYLE" < /dev/null; }
refresh()    { pkill -RTMIN+$SIGNAL waybar; }

current() { echo $(( $(brightnessctl get) * 100 / $(brightnessctl max) )); }

set_brightness() {
    local val=$1
    [ "$val" -lt "$MIN" ] && val=$MIN
    brightnessctl -q set "$val%"
    notify-send -a Brillo -i display-brightness -h string:x-dunst-stack-tag:brightness \
        -h "int:value:$val" "Brillo" "$val%"
    refresh
}

PERC=$(current)
choice=$(printf '%s\n' "󰃞  10%" "󰃞  25%" "󰃝  50%" "󰃟  75%" "󰃠  100%" "󰏫  Otro valor…" \
    | rofi_menu "󰃠  Brillo: $PERC%")

case "$choice" in
    "") exit 0 ;;
    *"Otro valor…")
        val=$(rofi_input "Brillo:" "Actual: $PERC%") || exit 0
        val=${val%\%}
        if [[ "$val" =~ ^[0-9]+$ ]] && [ "$val" -le 100 ]; then
            set_brightness "$val"
        else
            notify-send -a Brillo -u normal "Valor inválido" "Escribe un número de $MIN a 100"
        fi
        ;;
    *%)
        val=${choice##* }; set_brightness "${val%\%}" ;;
esac
