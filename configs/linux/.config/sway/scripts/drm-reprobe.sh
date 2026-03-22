#!/bin/sh
for connector in /sys/class/drm/card*-DP-*/status; do
    echo detect > "$connector" 2>/dev/null
done
