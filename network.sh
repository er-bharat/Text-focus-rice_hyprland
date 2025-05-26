#!/bin/bash

devices=$(nmcli -t -f DEVICE,TYPE,STATE device status)

output=""

# List Wi-Fi connections with SSIDs
while IFS=: read -r device type state; do
    if [[ "$type" == "wifi" && "$state" == "connected" ]]; then
        ssid=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)
        output+="   $ssid\n"
    fi
done <<< "$devices"

# List Ethernet and USB tethering connections
while IFS=: read -r device type state; do
    if [[ "$type" == "ethernet" && "$state" == "connected" ]]; then
        if [[ "$device" == usb* || "$device" == en*usb* || "$device" == enx* ]]; then
            output+="󰖟   USB Tethering ($device)\n"
        else
            output+="󰈀   Ethernet ($device)\n"
        fi
    fi
done <<< "$devices"

# If nothing found, mark disconnected
if [[ -z "$output" ]]; then
    echo "睊   Disconnected"
else
    # Remove trailing newline and print
    echo -e "$output" | sed '/^\s*$/d'
fi
