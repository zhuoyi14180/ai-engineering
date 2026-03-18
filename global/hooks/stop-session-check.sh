#!/usr/bin/env bash
# stop-session-check.sh
# Called by Claude Code's Stop hook when a session ends.
# Receives session info via stdin as JSON.
#
# Behavior by mode (detected via file existence):
#   automated mode (progress.json exists):
#     - Uncommitted changes present → exit 1 (block session end, prompt to commit)
#     - No uncommitted changes       → exit 0 (silent)
#   spec-coding / vibe-coding (no progress.json):
#     - Always exit 0 (silent, no interruption)
#
# Exit 0: allow session to end
# Exit 1: block session end (Claude Code will show the stderr message)

set -uo pipefail

# Only enforce in automated mode (progress.json exists in current or parent dirs)
find_progress_json() {
  local dir
  dir="$(pwd)"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/progress.json" ]]; then
      echo "$dir/progress.json"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  return 1
}

PROGRESS_FILE="$(find_progress_json 2>/dev/null || true)"

# Not automated mode — exit silently
if [[ -z "$PROGRESS_FILE" ]]; then
  exit 0
fi

# Automated mode — check for uncommitted changes
if ! git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
  exit 0
fi

UNCOMMITTED=$(git status --porcelain 2>/dev/null)

if [[ -n "$UNCOMMITTED" ]]; then
  echo "" >&2
  echo "[stop-check] Automated mode: uncommitted changes detected." >&2
  echo "[stop-check] progress.json was found at: $PROGRESS_FILE" >&2
  echo "[stop-check] Run /commit (or 'git add . && git commit') before ending the session." >&2
  echo "[stop-check] Uncommitted files:" >&2
  git status --short >&2
  exit 1
fi

exit 0
