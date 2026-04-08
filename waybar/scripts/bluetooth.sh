#!/bin/bash
STATUS=$(bluetoothctl show | grep Powered | awk '{print $2}')
DEVICE=$(bluetoothctl info | grep Name | awk '{print $2}')

if [ "$STATUS" = "yes" ]; then
    if [ -n "$DEVICE" ]; then
        echo "{\"text\":\"  $DEVICE\", \"tooltip\":\"Bluetooth: $DEVICE\"}"
    else
        echo "{\"text\":\"  On\", \"tooltip\":\"Bluetooth activo sin dispositivo\"}"
    fi
else
    echo "{\"text\":\"󰂲  Off\", \"tooltip\":\"Bluetooth desactivado\"}"
fi
