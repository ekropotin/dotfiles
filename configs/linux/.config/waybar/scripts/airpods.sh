#!/bin/bash
# AirPods quick-connect for waybar. Click the module to toggle the connection.
# On connect it also switches the card to A2DP and moves audio over, since
# wireplumber leaves the profile "off" until something asks for it.
MAC="98:1C:A2:EF:4C:BE"
CARD="bluez_card.${MAC//:/_}"
SINK="bluez_output.${MAC//:/_}"
BUSY="${XDG_RUNTIME_DIR:-/tmp}/waybar-airpods.busy"

is_connected() {
    bluetoothctl info "$MAC" 2>/dev/null | grep -q "Connected: yes"
}

# A marker older than a minute is a leftover from a run that was killed.
busy() {
    [ -e "$BUSY" ] && [ -z "$(find "$BUSY" -mmin +1 2>/dev/null)" ]
}

# Wait up to 5s for a pactl object matching $2 to show up in `pactl list short $1`.
wait_for() {
    for _ in $(seq 10); do
        pactl list short "$1" 2>/dev/null | grep -q "$2" && return 0
        sleep 0.5
    done
    return 1
}

route_audio() {
    wait_for cards "$CARD" || return 1
    pactl set-card-profile "$CARD" a2dp-sink >/dev/null 2>&1
    wait_for sinks "$SINK" || return 1
    local sink
    sink=$(pactl list short sinks | awk -v s="$SINK" '$2 ~ s {print $2; exit}')
    [ -n "$sink" ] || return 1
    pactl set-default-sink "$sink" >/dev/null 2>&1
    # Move anything already playing onto the AirPods.
    pactl list short sink-inputs 2>/dev/null | while read -r id _; do
        pactl move-sink-input "$id" "$sink" >/dev/null 2>&1
    done
}

case "$1" in
toggle)
    busy && exit 0
    trap 'rm -f "$BUSY"; pkill -RTMIN+8 waybar' EXIT INT TERM
    touch "$BUSY"
    pkill -RTMIN+8 waybar
    if is_connected; then
        timeout 20 bluetoothctl disconnect "$MAC" >/dev/null 2>&1
    else
        timeout 20 bluetoothctl connect "$MAC" >/dev/null 2>&1 && route_audio
    fi
    ;;
*)
    if busy; then
        echo '{"text":"󰋋","class":"busy"}'
    elif is_connected; then
        echo '{"text":"󰋋","class":"connected"}'
    else
        echo '{"text":"󰟎","class":"disconnected"}'
    fi
    ;;
esac
