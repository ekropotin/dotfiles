#!/bin/bash
# Triggered after resume by bt-resume-reconnect.service.
#
# After a long S3 suspend, bluez's ReconnectAttempts schedule (see the
# [Policy] block in main.conf) is long exhausted, so a bonded BLE
# peripheral that only advertises when touched (Logitech LIFT mouse) is
# never recaptured: bluez has given up initiating, so when the device
# advertises on a click nothing connects.
#
# An earlier version ran `bluetoothctl scan le` here on the theory that a
# discovery window lets bonded devices "auto-reconnect on sight". That is
# wrong: a passive discovery only *reports* adverts, it does not initiate a
# connection to a bonded HID device. Observed in practice — the resume hook
# scanned for the full 120s and the LIFT stayed `Connected: no`, while a
# plain `bluetoothctl connect <mac>` reconnected it instantly.
#
# So instead we loop explicit `connect` attempts against each bonded device
# that isn't connected. `connect` puts the controller in the LE initiating
# state, so the moment the device advertises (the first click) the pending
# attempt latches on. We retry for ~2 minutes to cover however long it
# takes you to touch the mouse.
set -u

DEADLINE=$((SECONDS + 120))   # keep trying for ~2 minutes after resume
RETRY_GAP=4                   # seconds between connect attempts per device

# Let the controller settle after resume before we start initiating.
sleep 3

# Bonded device MACs (Paired: yes), one per line.
bonded_devices() {
    bluetoothctl devices Bonded 2>/dev/null | awk '{print $2}'
}

is_connected() {
    bluetoothctl info "$1" 2>/dev/null | grep -q 'Connected: yes'
}

# Snapshot the bonded set once; reconnect any that come up on a click.
mapfile -t DEVICES < <(bonded_devices)
[ ${#DEVICES[@]} -eq 0 ] && exit 0

while (( SECONDS < DEADLINE )); do
    pending=0
    for mac in "${DEVICES[@]}"; do
        if is_connected "$mac"; then
            continue
        fi
        pending=1
        # Time-box each attempt; a not-yet-advertising device makes connect
        # hang until the controller gives up, and we'd rather move on.
        timeout 6 bluetoothctl connect "$mac" >/dev/null 2>&1
    done
    # Everything bonded is connected — nothing left to do.
    (( pending == 0 )) && exit 0
    sleep "$RETRY_GAP"
done
