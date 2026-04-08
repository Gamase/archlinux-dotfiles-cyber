#!/bin/bash
VOLUME=$(pamixer --get-volume)
MUTE=$(pamixer --get-mute)

if [ "$MUTE" = "true" ]; then
    CLASS="muted"
    ICON="󰝟"
elif [ "$VOLUME" -lt 33 ]; then
    CLASS="low"
    ICON="󰕿"
elif [ "$VOLUME" -lt 66 ]; then
    CLASS="medium"
    ICON="󰖀"
else
    CLASS="high"
    ICON="󰕾"
fi

FILLED=$((VOLUME / 10))
EMPTY=$((10 - FILLED))
BAR=""
for i in $(seq 1 $FILLED); do BAR+="█"; done
for i in $(seq 1 $EMPTY); do BAR+="░"; done

echo "{\"text\":\"$ICON $BAR $VOLUME%\", \"class\":\"$CLASS\", \"tooltip\":\"Volumen: $VOLUME%\"}"
