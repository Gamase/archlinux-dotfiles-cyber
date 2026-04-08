#!/bin/bash
SSID=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)
STATUS=$(nmcli -t -f WIFI g)

if [ "$STATUS" = "enabled" ] && [ -n "$SSID" ]; then
    echo "{\"text\":\"󰤨  $SSID\", \"tooltip\":\"WiFi: $SSID\"}"
elif [ "$STATUS" = "enabled" ]; then
    echo "{\"text\":\"󰤭  Sin red\", \"tooltip\":\"WiFi activo sin conexión\"}"
else
    echo "{\"text\":\"󰤭  Off\", \"tooltip\":\"WiFi desactivado\"}"
fi
