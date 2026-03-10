#!/usr/bin/env bash
# post-edit-format.sh
# Called by Claude Code's PostToolUse hook after Edit or Write tool calls.
# Receives tool info via stdin as JSON.
# Attempts to auto-format the modified file if a formatter is available.
#
# This script is best-effort: it should never fail in a way that blocks the workflow.

set -uo pipefail

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

format_file() {
  local file="$1"
  local ext="$2"

  case "$ext" in
    ts|tsx|js|jsx|mjs|cjs)
      if command -v prettier &>/dev/null; then
        prettier --write "$file" &>/dev/null && echo "[post-edit] Formatted: $file (prettier)"
      fi
      ;;
    py)
      if command -v ruff &>/dev/null; then
        ruff format "$file" &>/dev/null && echo "[post-edit] Formatted: $file (ruff)"
      fi
      ;;
    go)
      if command -v gofmt &>/dev/null; then
        gofmt -w "$file" &>/dev/null && echo "[post-edit] Formatted: $file (gofmt)"
      fi
      ;;
    java)
      if command -v google-java-format &>/dev/null; then
        google-java-format --replace "$file" &>/dev/null && echo "[post-edit] Formatted: $file (google-java-format)"
      fi
      ;;
    *)
      # No formatter for this file type
      ;;
  esac
}

format_file "$FILE_PATH" "$EXT"

exit 0
