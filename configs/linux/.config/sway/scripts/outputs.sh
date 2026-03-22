#!/bin/bash

BUILTIN=$(swaymsg -t get_outputs -r | jq -r '.[] | select(.name | startswith("eDP")) | .name' | head -1)

# Scale the built-in display
swaymsg output "$BUILTIN" scale 2

# Find the first connected external output (if any)
get_external() {
    swaymsg -t get_outputs -r | jq -r ".[] | select(.name != \"$BUILTIN\") | .name" | head -1
}

# Move all workspaces to a target output
move_all_workspaces() {
    local target="$1"
    swaymsg -t get_workspaces -r | jq -r '.[].name' | while read -r ws; do
        swaymsg "[workspace=\"$ws\"]" move workspace to output "$target" 2>/dev/null
    done
}

# Apply scaling, move workspaces to external display, and disable built-in
apply_external() {
    local ext="$1"
    swaymsg output "$ext" scale 2
    move_all_workspaces "$ext"
    swaymsg output "$BUILTIN" disable
}

# On startup: if external display is already connected, use it
ext=$(get_external)
if [[ -n "$ext" ]]; then
    apply_external "$ext"
fi

# Watch for output events (connect/disconnect)
swaymsg -t subscribe -m '["output"]' | while read -r event; do
    change=$(echo "$event" | jq -r '.change')

    sleep 1  # let Sway finish processing the output change
    ext=$(get_external)
    if [[ -n "$ext" ]]; then
        apply_external "$ext"
    else
        swaymsg output "$BUILTIN" enable
        move_all_workspaces "$BUILTIN"
    fi
done
