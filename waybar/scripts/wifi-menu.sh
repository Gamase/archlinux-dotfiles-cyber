#!/bin/bash
CURRENT=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)
STATUS=$(nmcli -t -f WIFI g)

if [ "$STATUS" = "enabled" ]; then
    TOGGLE="󰤭  Disable WiFi"
    NETWORKS=$(nmcli -t -f ssid,security dev wifi list | grep -v '^--' | awk -F: '{print $1}' | sed '/^$/d' | sort -u | head -6)
    LIST="$TOGGLE"
    while IFS= read -r net; do
        [ "$net" = "$CURRENT" ] && LIST="$LIST\n󰤨  $net (conectado)" || LIST="$LIST\n  $net"
    done <<< "$NETWORKS"
else
    LIST="󰤨  Enable WiFi"
fi

CHOICE=$(echo -e "$LIST" | rofi -dmenu -p "󰤨  WiFi: $CURRENT" -theme ~/.config/rofi/waybar.rasi)

case "$CHOICE" in
    "󰤭  Disable WiFi") nmcli radio wifi off ;;
    "󰤨  Enable WiFi") nmcli radio wifi on ;;
    *"(conectado)"*) ;;
    "  "*) 
        NET=$(echo "$CHOICE" | sed 's/^  //')
        foot -e bash -c "nmcli dev wifi connect '$NET'; read" ;;
esac
