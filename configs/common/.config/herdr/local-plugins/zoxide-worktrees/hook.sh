#!/usr/bin/env bash
set -euo pipefail

action="${1:-}"

path=$(printf '%s' "${HERDR_PLUGIN_EVENT_JSON:-}" | jq -r '[.. | objects | .worktree?.path? // empty][0] // empty')

if [[ -z "$path" ]]; then
  exit 0
fi

zoxide_bin=$(command -v zoxide || true)
if [[ -z "$zoxide_bin" ]]; then
  zoxide_bin="/opt/homebrew/bin/zoxide"
fi

if [[ ! -x "$zoxide_bin" ]]; then
  exit 0
fi

case "$action" in
  add)
    "$zoxide_bin" add -- "$path"
    ;;
  remove)
    "$zoxide_bin" remove -- "$path"
    ;;
esac
