#!/bin/bash
battery=$(solaar show 2>/dev/null | grep "Battery:" | tail -1 | grep -oP '\d+(?=%)')
if [ -n "$battery" ]; then
    echo "mouse ${battery}%"
fi
