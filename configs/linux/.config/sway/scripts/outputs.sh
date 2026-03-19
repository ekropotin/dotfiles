#!/bin/bash

OUTPUTS=$(swaymsg -t get_outputs)

if echo "$OUTPUTS" | grep -q '"name": "eDP-1"'; then
    swaymsg output eDP-1 scale 2
fi

if echo "$OUTPUTS" | grep -q '"name": "HDMI-A-1"'; then
    swaymsg output HDMI-A-1 scale 1.75
fi
