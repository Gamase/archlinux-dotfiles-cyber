#!/bin/bash
read -r SIG SSID < <(nmcli -t -e no -f ACTIVE,SIGNAL,SSID dev wifi list --rescan no | awk -F: '$1=="yes"{s=$2; sub(/^[^:]*:[^:]*:/, ""); print s, $0; exit}')
STATUS=$(nmcli -t -f WIFI g)
SSID=${SSID//\"/\\\"}

if [ "$STATUS" = "enabled" ] && [ -n "$SSID" ]; then
    if   [ "$SIG" -ge 75 ]; then ICON="󰤨"
    elif [ "$SIG" -ge 50 ]; then ICON="󰤥"
    elif [ "$SIG" -ge 25 ]; then ICON="󰤢"
    else ICON="󰤟"; fi
    IP=$(nmcli -g IP4.ADDRESS dev show "$(nmcli -t -f DEVICE,TYPE dev | awk -F: '$2=="wifi"{print $1; exit}')" | head -1)
    echo "{\"text\":\"$ICON  $SSID\", \"tooltip\":\"WiFi: $SSID\\nSeñal: $SIG%\\nIP: ${IP:-sin IP}\"}"
elif [ "$STATUS" = "enabled" ]; then
    echo "{\"text\":\"󰤯  Sin red\", \"tooltip\":\"WiFi activo sin conexión\"}"
else
    echo "{\"text\":\"󰤭  Off\", \"tooltip\":\"WiFi desactivado\"}"
fi
