#!/bin/bash

# Read battery info using upower
battery=$(upower -i $(upower -e | grep BAT) | grep -E "state|percentage" | awk '{print $2, $3}')

# Parse output
status=$(echo "$battery" | grep -iE "charging|discharging|fully-charged")
percent=$(echo "$battery" | grep -o '[0-9]*%')

# Choose icon based on percentage
icon=""
charge=${percent%\%}

if [ "$status" = "charging" ]; then
    icon=""  # Charging icon
elif [ "$charge" -ge 90 ]; then
    icon=""
elif [ "$charge" -ge 60 ]; then
    icon=""
elif [ "$charge" -ge 40 ]; then
    icon=""
elif [ "$charge" -ge 20 ]; then
    icon=""
else
    icon=""
fi

# Output with space between icon and percentage
echo "$icon  $percent"
