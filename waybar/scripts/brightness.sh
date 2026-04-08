#!/bin/bash
BRIGHT=$(brightnessctl get)
MAX=$(brightnessctl max)
PERC=$((BRIGHT * 100 / MAX))

if [ "$PERC" -lt 33 ]; then
    CLASS="low"
    ICON="󰃞"
elif [ "$PERC" -lt 66 ]; then
    CLASS="medium"
    ICON="󰃝"
else
    CLASS="high"
    ICON="󰃠"
fi

FILLED=$((PERC / 10))
EMPTY=$((10 - FILLED))
BAR=""
for i in $(seq 1 $FILLED); do BAR+="█"; done
for i in $(seq 1 $EMPTY); do BAR+="░"; done

echo "{\"text\":\"$ICON $BAR $PERC%\", \"class\":\"$CLASS\", \"tooltip\":\"Brillo: $PERC%\"}"
