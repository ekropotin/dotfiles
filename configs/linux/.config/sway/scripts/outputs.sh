#!/bin/bash

# Move all workspaces to the given output (default: eDP-1)
TARGET=${1:-eDP-1}

sleep 0.5

for ws in 1 2 3 4 5; do
    swaymsg "workspace --no-auto-back-and-forth number $ws; move workspace to output $TARGET"
done

swaymsg workspace number 1
