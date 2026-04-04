#!/bin/bash
if [ "$(cat /sys/class/power_supply/AC/online)" = "1" ]; then
    systemctl suspend
else
    systemctl suspend-then-hibernate
fi
