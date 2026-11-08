#!/bin/bash
# Estado de Bluetooth para Waybar: nombre completo y batería del dispositivo conectado

json_escape() { sed 's/\\/\\\\/g; s/"/\\"/g'; }

if ! bluetoothctl show | grep -q "Powered: yes"; then
    echo '{"text":"󰂲  Off", "tooltip":"Bluetooth desactivado", "class":"off"}'
    exit 0
fi

text=""
tooltip=""
while read -r _ mac name; do
    [ -z "$mac" ] && continue
    bat=$(bluetoothctl info "$mac" | sed -n 's/.*Battery Percentage:.*(\([0-9]*\)).*/\1/p')
    entry="$name"
    [ -n "$bat" ] && entry="$name ($bat%)"
    [ -z "$text" ] && text="$entry"
    tooltip+="$entry\\n"
done < <(bluetoothctl devices Connected)

if [ -n "$text" ]; then
    text=$(json_escape <<< "$text")
    tooltip=$(json_escape <<< "${tooltip%\\n}" | sed 's/\\\\n/\\n/g')
    echo "{\"text\":\"󰂱  $text\", \"tooltip\":\"$tooltip\", \"class\":\"connected\"}"
else
    echo '{"text":"  On", "tooltip":"Bluetooth activo sin dispositivo\nClic: menú · Clic derecho: gestionar", "class":"on"}'
fi
