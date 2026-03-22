#!/usr/bin/env bash
# pre-bash-check.sh
# Called by Claude Code's PreToolUse hook before any Bash command execution.
# Receives the command via stdin as JSON: {"tool_name": "Bash", "tool_input": {"command": "..."}}
#
# Exit 0: allow the command
# Exit non-0: block the command (Claude Code will show the stderr message)

set -euo pipefail

# Read the JSON input from stdin
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input', {}).get('command', ''))" 2>/dev/null || echo "")

if [ -z "$COMMAND" ]; then
  exit 0
fi

# Block patterns — destructive operations that require explicit user confirmation
BLOCKED_PATTERNS=(
  "rm -rf /"
  "rm -rf ~"
  "rm -rf \$HOME"
  "git push --force origin main"
  "git push --force origin master"
  "git push -f origin main"
  "git push -f origin master"
  "DROP TABLE"
  "DROP DATABASE"
  "chmod -R 777 /"
  ":(){ :|:& };:"  # fork bomb
)

for pattern in "${BLOCKED_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qF "$pattern"; then
    echo "BLOCKED: Potentially destructive command detected: '$pattern'" >&2
    echo "If you intended this, please run it manually in the terminal." >&2
    exit 1
  fi
done

exit 0
