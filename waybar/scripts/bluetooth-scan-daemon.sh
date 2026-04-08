#!/bin/bash
while true; do
    expect -c '
        spawn bluetoothctl
        expect "#"
        send "scan on\r"
        sleep 30
        send "scan off\r"
        sleep 2
        send "exit\r"
        expect eof
    '
    sleep 5
done
