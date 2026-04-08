#!/bin/bash
BATTERY_PATH="BAT1"
CAPACITY=$(cat /sys/class/power_supply/$BATTERY_PATH/capacity)
STATUS=$(cat /sys/class/power_supply/$BATTERY_PATH/status)

if [ "$STATUS" = "Charging" ]; then
    CLASS="charging"
    ICON="󰂄"
elif [ "$CAPACITY" -lt 20 ]; then
    CLASS="low"
    ICON="󰁺"
elif [ "$CAPACITY" -lt 40 ]; then
    CLASS="medium"
    ICON="󰁼"
elif [ "$CAPACITY" -lt 60 ]; then
    CLASS="medium"
    ICON="󰁿"
elif [ "$CAPACITY" -lt 80 ]; then
    CLASS="high"
    ICON="󰂁"
else
    CLASS="high"
    ICON="󰁹"
fi

FILLED=$((CAPACITY / 10))
EMPTY=$((10 - FILLED))
BAR=""
for i in $(seq 1 $FILLED); do BAR+="█"; done
for i in $(seq 1 $EMPTY); do BAR+="░"; done

TOOLTIP="Batería: $CAPACITY%\nEstado: $STATUS"
echo "{\"text\":\"$ICON $BAR $CAPACITY%\", \"class\":\"$CLASS\", \"tooltip\":\"$TOOLTIP\"}"
