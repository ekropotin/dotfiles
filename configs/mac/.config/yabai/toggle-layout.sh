#!/bin/bash

# Get the current layout of the focused space
current_layout=$(yabai -m query --spaces --space | jq -r '.type')

if [[ "$current_layout" == "bsp" ]]; then
    yabai -m config layout stack
elif [[ "$current_layout" == "stack" ]]; then
    yabai -m config layout bsp
else
    yabai -m config layout bsp
fi
