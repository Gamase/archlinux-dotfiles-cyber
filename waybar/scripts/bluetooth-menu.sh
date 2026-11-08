#!/bin/bash
# Menú Bluetooth para Waybar (rofi).
# - Dispositivos emparejados primero, con batería si está disponible
# - Conexión con timeout + reintentos, y cambia la salida de audio
# - Escaneo solo bajo demanda para emparejar dispositivos nuevos

THEME=~/.config/rofi/waybar.rasi
SIGNAL=8   # debe coincidir con "signal" en la config de waybar

rofi_menu() { rofi -dmenu -i -p "$1" -theme "$THEME"; }
notify()    { notify-send -a Bluetooth -i bluetooth -h string:x-dunst-stack-tag:bluetooth "$@"; }
refresh()   { pkill -RTMIN+$SIGNAL waybar; }

is_connected() { bluetoothctl info "$1" | grep -q "Connected: yes"; }
dev_name()     { bluetoothctl info "$1" | sed -n 's/^\s*Name: //p'; }

battery() {
    local b
    b=$(bluetoothctl info "$1" | sed -n 's/.*Battery Percentage:.*(\([0-9]*\)).*/\1/p')
    [ -n "$b" ] && echo " 󰁹 $b%"
}

set_audio_sink() {
    # Espera a que PipeWire cree el sink del dispositivo y lo pone por defecto
    local sink="bluez_output.${1//:/_}" i name
    for i in $(seq 1 10); do
        name=$(pactl list short sinks | awk -v s="$sink" 'index($2, s)==1 {print $2; exit}')
        if [ -n "$name" ]; then
            pactl set-default-sink "$name"
            return
        fi
        sleep 0.5
    done
}

connect() {
    local mac=$1 name attempt since
    name=$(dev_name "$mac")
    since=$(date '+%Y-%m-%d %H:%M:%S')
    notify "Conectando…" "$name"
    for attempt in 1 2 3; do
        bluetoothctl --timeout 10 connect "$mac" >/dev/null 2>&1
        if is_connected "$mac"; then
            set_audio_sink "$mac"
            notify "Conectado" "$name$(battery "$mac")"
            refresh
            return 0
        fi
        # Limpia un estado a medias antes de reintentar
        bluetoothctl disconnect "$mac" >/dev/null 2>&1
        sleep 1
    done
    # "Permission denied" = el dispositivo perdió la llave de emparejamiento de esta PC
    if journalctl -u bluetooth --since "$since" --no-pager 2>/dev/null | grep -q "$mac: Permission denied"; then
        notify -u critical "No se pudo conectar" "$name olvidó esta PC.\nClic derecho → Olvidar dispositivo, ponlo en modo emparejamiento y usa «Buscar dispositivos nuevos»."
    else
        notify -u critical "No se pudo conectar" "$name\n¿Está encendido y fuera de su estuche? ¿Conectado a otro equipo?"
    fi
    refresh
    return 1
}

disconnect() {
    local name
    name=$(dev_name "$1")
    bluetoothctl disconnect "$1" >/dev/null 2>&1
    notify "Desconectado" "$name"
    refresh
}

device_menu() {
    local mac=$1 name opts choice
    name=$(dev_name "$mac")
    if is_connected "$mac"; then
        opts="󰂲  Desconectar\n󰆴  Olvidar dispositivo"
    else
        opts="󰂱  Conectar\n󰆴  Olvidar dispositivo"
    fi
    choice=$(echo -e "$opts" | rofi_menu "$name")
    case "$choice" in
        *Conectar)     connect "$mac" ;;
        *Desconectar)  disconnect "$mac" ;;
        *Olvidar*)     bluetoothctl remove "$mac" >/dev/null && notify "Dispositivo olvidado" "$name"; refresh ;;
    esac
}

scan_and_pair() {
    notify -t 10000 "Buscando dispositivos…" "Pon tus audífonos en modo emparejamiento"
    bluetoothctl --timeout 10 scan on >/dev/null 2>&1

    local paired lines="" mac name
    paired=$(bluetoothctl devices Paired | awk '{print $2}')
    while read -r _ mac name; do
        [ -z "$mac" ] && continue
        grep -qx "$mac" <<< "$paired" && continue
        # Omite dispositivos sin nombre real (BlueZ usa la MAC con guiones)
        [ "$name" = "${mac//:/-}" ] && continue
        lines+="$name  [$mac]\n"
    done < <(bluetoothctl devices)

    if [ -z "$lines" ]; then
        notify "No se encontraron dispositivos nuevos"
        return
    fi

    local choice
    choice=$(echo -e "${lines%\\n}" | rofi_menu "Emparejar")
    [ -z "$choice" ] && return
    mac=$(sed -n 's/.*\[\(.*\)\]$/\1/p' <<< "$choice")
    name=${choice%  \[*}

    notify "Emparejando…" "$name"
    if "$(dirname "$0")/bluetooth-pair.sh" "$mac" 20; then
        set_audio_sink "$mac"
        notify "Emparejado y conectado" "$name$(battery "$mac")"
        refresh
    else
        notify -u critical "No se pudo emparejar" "$name"
    fi
}

# --- Menú principal ---
if ! bluetoothctl show | grep -q "Powered: yes"; then
    choice=$(echo -e "  Encender Bluetooth" | rofi_menu "󰂲  Bluetooth: Off")
    if [ -n "$choice" ]; then
        rfkill unblock bluetooth
        bluetoothctl power on >/dev/null
        refresh
    fi
    exit 0
fi

declare -A MACS
opts=""
while read -r _ mac name; do
    [ -z "$mac" ] && continue
    if is_connected "$mac"; then
        label="󰂱  $name$(battery "$mac")  (conectado)"
    else
        label="  $name"
    fi
    MACS["$label"]=$mac
    opts+="$label\n"
done < <(bluetoothctl devices Paired)

opts+="󰂰  Buscar dispositivos nuevos\n󰂲  Apagar Bluetooth"
choice=$(echo -e "$opts" | rofi_menu "  Bluetooth")

case "$choice" in
    "")                       exit 0 ;;
    *"Buscar dispositivos"*)  scan_and_pair ;;
    *"Apagar Bluetooth")      bluetoothctl power off >/dev/null; refresh ;;
    *)
        mac=${MACS["$choice"]}
        [ -z "$mac" ] && exit 0
        # Clic directo: alterna conectar/desconectar. Clic derecho en waybar abre submenú.
        if [ "$1" = "--manage" ]; then
            device_menu "$mac"
        elif is_connected "$mac"; then
            disconnect "$mac"
        else
            connect "$mac"
        fi
        ;;
esac
