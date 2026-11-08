#!/bin/bash
# Menú WiFi para Waybar (rofi).
# - Redes ordenadas por señal, con candado si piden contraseña
# - Pide contraseña (o usuario + contraseña en redes 802.1X) dentro de rofi
# - Si la contraseña es incorrecta, no deja un perfil roto guardado
# - Clic en la red conectada: desconectar / olvidar / ver detalles

THEME=~/.config/rofi/waybar.rasi
SIGNAL=9   # debe coincidir con "signal" en la config de waybar
IFACE=$(nmcli -t -f DEVICE,TYPE dev | awk -F: '$2=="wifi"{print $1; exit}')

LIST_STYLE='window { width: 380px; } listview { lines: 8; }'
# El tema base oculta el inputbar; aquí se activa para escribir
INPUT_STYLE='window { width: 380px; }
inputbar { enabled: true; padding: 8px 12px; border-radius: 8px; background-color: rgba(0, 30, 80, 60%); children: [prompt, entry]; spacing: 8px; }
prompt { background-color: transparent; }
entry { background-color: transparent; text-color: #66bbff; placeholder-color: #33557a; }
listview { enabled: false; }
textbox { text-color: #66bbff; background-color: transparent; }'

rofi_menu() { rofi -dmenu -i -p "$1" -theme "$THEME" -theme-str "$LIST_STYLE"; }
# rofi_input <prompt> <mensaje> [--password]
rofi_input() {
    rofi -dmenu -p "$1" -mesg "$2" ${3:+-password} -theme "$THEME" -theme-str "$INPUT_STYLE" \
        -theme-str "entry { placeholder: \"${1%%:*}\"; }" < /dev/null
}
notify()  { notify-send -a WiFi -i network-wireless -h string:x-dunst-stack-tag:wifi "$@"; }
refresh() { pkill -RTMIN+$SIGNAL waybar; }

signal_icon() {
    if   [ "$1" -ge 75 ]; then echo "󰤨"
    elif [ "$1" -ge 50 ]; then echo "󰤥"
    elif [ "$1" -ge 25 ]; then echo "󰤢"
    else echo "󰤟"; fi
}

# Nombre del perfil guardado para un SSID (vacío si no existe)
saved_profile() {
    local name type
    while IFS=: read -r name type; do
        [ "$type" = "802-11-wireless" ] || continue
        if [ "$(nmcli -g 802-11-wireless.ssid con show "$name" 2>/dev/null)" = "$1" ]; then
            echo "$name"
            return
        fi
    done < <(nmcli -t -e no -f NAME,TYPE con show)
}

connected_ok() {
    notify "Conectado" "$1"
    refresh
}

connect_failed() {
    notify -u critical "No se pudo conectar" "$1\n$2"
    refresh
}

# Conecta a una red nueva. $2 = SECURITY de nmcli
connect_new() {
    local ssid=$1 sec=$2 pass user out

    if [[ "$sec" == *802.1X* ]]; then
        # WPA-Enterprise (escuelas, oficinas): PEAP + MSCHAPv2 es lo más común
        user=$(rofi_input "Usuario:" "󰒃  $ssid (empresarial)") || return
        [ -z "$user" ] && return
        pass=$(rofi_input "Contraseña:" "󰒃  $ssid — $user" --password) || return
        notify "Conectando…" "$ssid"
        nmcli con add type wifi ifname "$IFACE" con-name "$ssid" ssid "$ssid" \
            wifi-sec.key-mgmt wpa-eap 802-1x.eap peap 802-1x.phase2-auth mschapv2 \
            802-1x.identity "$user" 802-1x.password "$pass" >/dev/null 2>&1
        if out=$(nmcli --wait 30 con up id "$ssid" 2>&1); then
            connected_ok "$ssid"
        else
            nmcli con delete id "$ssid" >/dev/null 2>&1
            connect_failed "$ssid" "Usuario o contraseña incorrectos"
        fi
        return
    fi

    if [ -z "$sec" ] || [[ "$sec" =~ ^OWE ]]; then
        # Abierta u OWE (cifrada pero sin contraseña)
        notify "Conectando…" "$ssid"
        out=$(nmcli --wait 30 dev wifi connect "$ssid" ifname "$IFACE" 2>&1)
    else
        pass=$(rofi_input "Contraseña:" "  $ssid" --password) || return
        [ -z "$pass" ] && return
        notify "Conectando…" "$ssid"
        out=$(nmcli --wait 30 dev wifi connect "$ssid" password "$pass" ifname "$IFACE" 2>&1)
    fi

    if [ $? -eq 0 ]; then
        connected_ok "$ssid"
    else
        # No dejar guardado un perfil con la contraseña mala
        nmcli con delete id "$ssid" >/dev/null 2>&1
        if [[ "$out" == *[Ss]ecrets* || "$out" == *password* ]]; then
            connect_failed "$ssid" "Contraseña incorrecta"
        else
            connect_failed "$ssid" "$(sed -n 's/^Error: //p' <<< "$out" | head -1)"
        fi
    fi
}

# Conecta usando un perfil ya guardado; si la contraseña cambió, la vuelve a pedir
connect_saved() {
    local ssid=$1 profile=$2 sec=$3 pass
    notify "Conectando…" "$ssid"
    if nmcli --wait 30 con up id "$profile" >/dev/null 2>&1; then
        connected_ok "$ssid"
        return
    fi
    if [ -n "$sec" ] && [[ ! "$sec" =~ ^OWE ]] && [[ "$sec" != *802.1X* ]]; then
        pass=$(rofi_input "Contraseña:" "  $ssid — la guardada no funcionó" --password) || { refresh; return; }
        [ -z "$pass" ] && return
        nmcli con modify id "$profile" wifi-sec.psk "$pass"
        if nmcli --wait 30 con up id "$profile" >/dev/null 2>&1; then
            connected_ok "$ssid"
            return
        fi
    fi
    connect_failed "$ssid" "¿Está en rango? Prueba «Olvidar red» y vuelve a conectarte."
}

connected_menu() {
    local ssid=$1 profile choice ip
    profile=$(saved_profile "$ssid")
    choice=$(echo -e "󰤭  Desconectar\n󰋼  Detalles\n󰆴  Olvidar red" | rofi_menu "$ssid")
    case "$choice" in
        *Desconectar) nmcli dev disconnect "$IFACE" >/dev/null && notify "Desconectado" "$ssid"; refresh ;;
        *Detalles)
            ip=$(nmcli -g IP4.ADDRESS,IP4.GATEWAY,IP4.DNS dev show "$IFACE" | paste -sd'|')
            IFS='|' read -r addr gw dns <<< "$ip"
            notify -t 10000 "$ssid" "IP: ${addr:-?}\nGateway: ${gw:-?}\nDNS: ${dns:-?}" ;;
        *Olvidar*)
            [ -n "$profile" ] && nmcli con delete id "$profile" >/dev/null && notify "Red olvidada" "$ssid"
            refresh ;;
    esac
}

hidden_network() {
    local ssid pass out
    ssid=$(rofi_input "SSID:" "󰈈  Red oculta") || return
    [ -z "$ssid" ] && return
    pass=$(rofi_input "Contraseña:" "  $ssid — vacío si es abierta" --password) || return
    notify "Conectando…" "$ssid"
    if [ -n "$pass" ]; then
        out=$(nmcli --wait 30 dev wifi connect "$ssid" password "$pass" hidden yes ifname "$IFACE" 2>&1)
    else
        out=$(nmcli --wait 30 dev wifi connect "$ssid" hidden yes ifname "$IFACE" 2>&1)
    fi
    if [ $? -eq 0 ]; then
        connected_ok "$ssid"
    else
        nmcli con delete id "$ssid" >/dev/null 2>&1
        connect_failed "$ssid" "$(sed -n 's/^Error: //p' <<< "$out" | head -1)"
    fi
}

# --- Menú principal ---
if [ "$(nmcli -t -f WIFI g)" != "enabled" ]; then
    choice=$(echo -e "󰤨  Encender WiFi" | rofi_menu "󰤭  WiFi: Off")
    if [ -n "$choice" ]; then
        nmcli radio wifi on
        notify "WiFi encendido"
        refresh
    fi
    exit 0
fi

RESCAN=no
[ "$1" = "--rescan" ] && RESCAN=yes

current=$(nmcli -t -e no -f ACTIVE,SSID dev wifi list --rescan "$RESCAN" | sed -n 's/^yes://p' | head -1)

# SSID va al final para que los ":" del nombre no rompan el parseo
declare -A SEEN SSIDS SECS
opts=""
while IFS=: read -r inuse sig sec ssid; do
    [ -z "$ssid" ] && continue
    [ -n "${SEEN[$ssid]}" ] && continue
    SEEN["$ssid"]=1
    [ "$sec" = "--" ] && sec=""
    lock=""
    [ -n "$sec" ] && [[ ! "$sec" =~ ^OWE ]] && lock="  "
    if [ "$ssid" = "$current" ]; then
        label="$(signal_icon "$sig")  $ssid$lock  (conectado)"
        opts="$label"$'\n'"$opts"
    else
        label="$(signal_icon "$sig")  $ssid$lock"
        opts+="$label"$'\n'
    fi
    SSIDS["$label"]=$ssid
    SECS["$label"]=$sec
done < <(nmcli -t -e no -f IN-USE,SIGNAL,SECURITY,SSID dev wifi list --rescan no | sort -t: -k2,2nr)

opts+=$'󰑐  Buscar redes\n󰈈  Red oculta…\n󰤭  Apagar WiFi'
choice=$(printf '%s\n' "$opts" | rofi_menu "󰤨  WiFi${current:+: $current}")

case "$choice" in
    "")                exit 0 ;;
    *"Buscar redes")   notify -t 2000 "Buscando redes…"; exec "$0" --rescan ;;
    *"Red oculta…")    hidden_network ;;
    *"Apagar WiFi")    nmcli radio wifi off; notify "WiFi apagado"; refresh ;;
    *)
        ssid=${SSIDS["$choice"]}
        sec=${SECS["$choice"]}
        [ -z "$ssid" ] && exit 0
        if [ "$ssid" = "$current" ]; then
            connected_menu "$ssid"
        elif profile=$(saved_profile "$ssid") && [ -n "$profile" ]; then
            connect_saved "$ssid" "$profile" "$sec"
        else
            connect_new "$ssid" "$sec"
        fi
        ;;
esac
