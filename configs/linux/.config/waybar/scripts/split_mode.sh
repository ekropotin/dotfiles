#!/bin/bash

trap 'exit 0' PIPE

get_layout() {
  local layout
  layout=$(swaymsg -t get_tree | jq -r '[recurse(.nodes[]?, .floating_nodes[]?) | select(.nodes[]?.focused == true or .floating_nodes[]?.focused == true) | .layout] | last')
  case "$layout" in
    splith) echo "H" ;;
    splitv) echo "V" ;;
    *)      echo "-" ;;
  esac
}

get_layout

swaymsg -t subscribe -m '["window","binding"]' | jq --unbuffered -r '.change' | while read -r _; do
  get_layout
done
