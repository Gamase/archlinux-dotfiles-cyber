#!/bin/bash
# Empareja (con bonding) un dispositivo en una sola sesión de bluetoothctl con agente activo.
# Uso: bluetooth-pair.sh MAC [segundos_de_búsqueda]
# Sale con 0 si el dispositivo queda Bonded y conectado.
MAC=$1
WAIT=${2:-60}
[ -z "$MAC" ] && { echo "Uso: $0 MAC [segundos]"; exit 2; }

bluetoothctl remove "$MAC" >/dev/null 2>&1

expect -c "
    set timeout $WAIT
    log_user 0
    spawn bluetoothctl
    send \"agent NoInputNoOutput\r\"
    send \"default-agent\r\"
    send \"scan on\r\"
    expect {
        \"Device $MAC\" {}
        timeout { send \"exit\r\"; exit 3 }
    }
    send \"scan off\r\"
    set timeout 30
    send \"pair $MAC\r\"
    expect {
        \"Pairing successful\" {}
        \"Failed to pair\" { send \"exit\r\"; exit 4 }
        timeout { send \"exit\r\"; exit 4 }
    }
    send \"trust $MAC\r\"
    sleep 1
    send \"connect $MAC\r\"
    expect {
        \"Connection successful\" {}
        timeout {}
    }
    sleep 2
    send \"exit\r\"
    expect eof
"
rc=$?
[ $rc -ne 0 ] && exit $rc

bluetoothctl info "$MAC" | grep -q "Bonded: yes" || exit 5
bluetoothctl info "$MAC" | grep -q "Connected: yes" || bluetoothctl --timeout 10 connect "$MAC" >/dev/null 2>&1
bluetoothctl info "$MAC" | grep -q "Connected: yes"
