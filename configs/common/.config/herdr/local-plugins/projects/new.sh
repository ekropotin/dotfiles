#!/usr/bin/env bash
# Overlay prompt: ask for a project name, create ~/Projects/<slug>, open a herdr workspace, start Claude.
set -euo pipefail

PROJECTS_DIR="$HOME/Projects"
# Claude launch flags: sonnet, auto mode, with bypass-permissions available (not enabled by default).
CLAUDE_FLAGS=(--model sonnet --permission-mode auto --allow-dangerously-skip-permissions)

read -r -p "Project name: " name || exit 0
name="${name#"${name%%[![:space:]]*}"}"
name="${name%"${name##*[![:space:]]}"}"
[[ -n "$name" ]] || exit 0

slug=$(printf '%s' "$name" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')
if [[ -z "$slug" ]]; then
  echo "Name has no usable characters." >&2
  sleep 2
  exit 1
fi
dir="$PROJECTS_DIR/$slug"

# First value of a key anywhere in the herdr JSON result.
jfirst() { jq -r --arg k "$1" '[.. | objects | .[$k]? // empty][0] // empty'; }

# Prints the id of an open workspace whose label is <slug> (labels look like "[5] slug"), or nothing.
find_workspace() {
  herdr workspace list | jq -r --arg slug "$slug" \
    '[.result.workspaces[] | select((.label | sub("^\\[[0-9]+\\] "; "")) == $slug) | .workspace_id][0] // empty'
}

# Creates the workspace, echoes "<workspace_id> <root_pane_id>".
create_workspace() {
  local out ws pane
  out=$(herdr workspace create --cwd "$dir" --label "$slug" --focus)
  ws=$(printf '%s' "$out" | jfirst workspace_id)
  pane=$(printf '%s' "$out" | jfirst pane_id)
  if [[ -z "$pane" ]]; then
    pane=$(herdr pane list --workspace "$ws" | jfirst pane_id)
  fi
  if [[ -z "$ws" || -z "$pane" ]]; then
    echo "Could not read workspace/pane id from herdr: $out" >&2
    sleep 4
    exit 1
  fi
  echo "$ws $pane"
}

if [[ -d "$dir" ]]; then
  ws=$(find_workspace)
  if [[ -n "$ws" ]]; then
    herdr workspace focus "$ws" >/dev/null
    exit 0
  fi
  read -r ws pane < <(create_workspace)
  herdr agent start "$slug" --kind claude --pane "$pane" -- "${CLAUDE_FLAGS[@]}" >/dev/null
  exit 0
fi

mkdir -p "$dir"
read -r ws pane < <(create_workspace)
if ! herdr agent start "$slug" --kind claude --pane "$pane" -- "${CLAUDE_FLAGS[@]}" "/new-project $name" >/dev/null 2>&1; then
  herdr pane run "$pane" claude "${CLAUDE_FLAGS[@]}" "\"/new-project $name\"" >/dev/null
fi
