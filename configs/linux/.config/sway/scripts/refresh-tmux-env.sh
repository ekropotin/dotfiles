#!/bin/sh
# Propagate SWAYSOCK to tmux server and all running panes.
# Called by sway via exec_always on every config load/reload.
# Only pushes to existing panes if the socket actually changed.

SOCK=$(ls /run/user/$(id -u)/sway-ipc.*.sock 2>/dev/null | head -1)
[ -z "$SOCK" ] && exit 0

# On fresh sway start, tmux may not be running yet — wait for it
retries=0
while ! tmux info >/dev/null 2>&1; do
  retries=$((retries + 1))
  [ "$retries" -gt 10 ] && exit 0
  sleep 1
done

OLD=$(tmux show-environment -g SWAYSOCK 2>/dev/null | sed 's/^SWAYSOCK=//')
tmux setenv -g SWAYSOCK "$SOCK" 2>/dev/null || exit 0

[ "$SOCK" = "$OLD" ] && exit 0

for pane in $(tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index}' 2>/dev/null); do
  tmux send-keys -t "$pane" " export SWAYSOCK=$SOCK" Enter
done
