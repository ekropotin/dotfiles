#!/bin/bash

layout=$(swaymsg -t get_tree | jq '.. | objects? | select(.focused? == true) | .layout' -r)

case "$layout" in
  splith) echo " H" ;;   # horizontal
  splitv) echo " V" ;;   # vertical
  *)      echo " Auto" ;; # default or tabbed/stacked
esac
