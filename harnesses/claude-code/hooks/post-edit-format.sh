#!/usr/bin/env bash
# post-edit-format.sh
# Called by Claude Code's PostToolUse hook after Edit or Write tool calls.
# Receives tool info via stdin as JSON.
# Attempts to auto-format the modified file if a formatter is available.
#
# This script is best-effort: it should never fail in a way that blocks the workflow.
# On success: prints "[post-edit] Formatted: <file> (<formatter>)" to stdout.
# On failure: prints a warning to stderr (exit 0, does not block the workflow).

set -uo pipefail

ERRFILE="/tmp/post-edit-format-err-$$"
trap 'rm -f "$ERRFILE"' EXIT

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
inp = d.get('tool_input', {})
# Edit tool uses 'file_path', Write tool uses 'file_path'
print(inp.get('file_path', ''))
" 2>/dev/null || echo "")

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

EXT="${FILE_PATH##*.}"

run_formatter() {
  local name="$1"; shift
  if "$@" >/dev/null 2>"$ERRFILE"; then
    echo "[post-edit] Formatted: $FILE_PATH ($name)"
  else
    echo "[post-edit] WARNING: $name failed on $FILE_PATH" >&2
    cat "$ERRFILE" >&2
  fi
}

case "$EXT" in
  ts|tsx|js|jsx|mjs|cjs)
    if command -v prettier &>/dev/null; then
      run_formatter "prettier" prettier --write "$FILE_PATH"
    fi
    ;;
  py)
    if command -v ruff &>/dev/null; then
      run_formatter "ruff" ruff format "$FILE_PATH"
    fi
    ;;
  go)
    if command -v gofmt &>/dev/null; then
      run_formatter "gofmt" gofmt -w "$FILE_PATH"
    fi
    ;;
  java)
    if command -v google-java-format &>/dev/null; then
      run_formatter "google-java-format" google-java-format --replace "$FILE_PATH"
    fi
    ;;
  *)
    # No formatter for this file type
    ;;
esac

exit 0
