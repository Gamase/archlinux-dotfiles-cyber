#!/bin/bash

mostrar_menu() {
    STATUS=$(bluetoothctl show | grep Powered | awk '{print $2}')

    if [ "$STATUS" != "yes" ]; then
        CHOICE=$(echo -e "  Enable Bluetooth" | rofi -dmenu -p "󰂲  Bluetooth: Off" -theme ~/.config/rofi/waybar.rasi)
        case "$CHOICE" in
            "  Enable Bluetooth")
                rfkill unblock bluetooth
                bluetoothctl power on ;;
        esac
        return
    fi

    CONNECTED_MAC=$(bluetoothctl info | grep "Device" | awk '{print $2}')
    DEVICES=$(bluetoothctl devices | awk '{mac=$2; name=""; for(i=3;i<=NF;i++) name=name$i" "; gsub(/ $/,"",name); print mac"|"name}')

    OPTIONS="󰂲  Disable Bluetooth"
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        MAC=$(echo "$line" | cut -d'|' -f1)
        NAME=$(echo "$line" | cut -d'|' -f2)
        [ -z "$NAME" ] && continue
        if [ "$MAC" = "$CONNECTED_MAC" ]; then
            OPTIONS="$OPTIONS\n󰂱  $NAME (conectado)"
        else
            OPTIONS="$OPTIONS\n  $NAME"
        fi
    done <<< "$DEVICES"

    CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -p "  Bluetooth: On" -theme ~/.config/rofi/waybar.rasi)

    case "$CHOICE" in
        "󰂲  Disable Bluetooth")
            bluetoothctl power off ;;
        "󰂱  "*"(conectado)")
            NAME=$(echo "$CHOICE" | sed 's/^󰂱  //' | sed 's/ (conectado)//')
            MAC=$(bluetoothctl devices | grep "$NAME" | awk '{print $2}')
            bluetoothctl disconnect "$MAC" ;;
        "  "*)
            NAME=$(echo "$CHOICE" | sed 's/^  //')
            MAC=$(bluetoothctl devices | grep "$NAME" | awk '{print $2}')
            bluetoothctl trust "$MAC" 2>/dev/null
            bluetoothctl connect "$MAC" ;;
    esac
}

mostrar_menu
