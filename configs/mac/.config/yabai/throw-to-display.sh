#!/bin/bash

# Send the focused window to the next display, and tile it there.
#
# yabai's own `window --display` needs the scripting addition, i.e. injection
# into Dock.app, i.e. SIP partially disabled -- see the comment at the top of
# yabairc. This does the same job through the public Accessibility API only.
#
# How it works: a display is just a region of the global coordinate plane, so
# putting a window on another one is a plain frame change, and the window
# server reassigns the space membership itself as a side effect. The catch is
# that yabai refuses `--move abs` on a window it manages ("cannot move a
# managed window"), so the window is floated for the move and re-tiled after.
# yabai's tree picks up the new space on the way, as long as the window keeps
# focus -- which it does, since this acts on the focused window by definition.
#
# With two displays this is Omarchy's SUPER+D, send-and-bring-back; with more
# it cycles forward through them.

set -uo pipefail

win=$(yabai -m query --windows --window 2>/dev/null) || exit 0
if [ -z "$win" ]; then
    exit 0
fi

displays=$(yabai -m query --displays)
count=$(jq 'length' <<<"$displays")
if [ "$count" -lt 2 ]; then
    exit 0
fi

cur=$(jq -r '.display' <<<"$win")
next=$(( cur % count + 1 ))

# Land inside the target display's rect; the exact spot doesn't matter for a
# window that will be re-tiled, it just has to be unambiguously on that display.
read -r x y < <(jq -r --argjson i "$next" '
    .[] | select(.index == $i) | .frame | "\(.x + 40 | floor) \(.y + 40 | floor)"
' <<<"$displays")

# A window that was already floating -- unmanaged by rule, or floated by hand --
# stays floating; only re-tile one that yabai was managing.
if [ "$(jq -r '."is-floating"' <<<"$win")" = "true" ]; then
    yabai -m window --move abs:"$x":"$y"
    exit 0
fi

yabai -m window --toggle float
yabai -m window --move abs:"$x":"$y"
sleep 0.3
yabai -m window --toggle float
