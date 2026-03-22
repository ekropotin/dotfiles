#!/bin/sh
# Propagate SWAYSOCK to tmux server and all running panes.
# Called by sway via exec_always on every config load/reload.

SOCK=$(swaymsg --socket '' --get-socketpath 2>/dev/null || ls /run/user/$(id -u)/sway-ipc.*.sock 2>/dev/null | head -1)
[ -z "$SOCK" ] && exit 0

tmux setenv -g SWAYSOCK "$SOCK" 2>/dev/null || exit 0

for pane in $(tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index}' 2>/dev/null); do
  tmux send-keys -t "$pane" " export SWAYSOCK=$SOCK" Enter
done
