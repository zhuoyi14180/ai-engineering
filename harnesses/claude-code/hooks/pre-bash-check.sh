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

# Block patterns — destructive shell operations requiring explicit user confirmation.
# These patterns match actual command invocations, NOT file content containing these strings.
# The check uses word-boundary matching to avoid false positives on SQL in source files.

# Git force-push to protected branches (exact match on git push commands)
if echo "$COMMAND" | grep -qE '^\s*git\s+push\s+.*(-f|--force)\s+(origin\s+)?(main|master)\b'; then
  echo "BLOCKED: Force push to main/master is not allowed." >&2
  echo "If you intended this, please run it manually in the terminal." >&2
  exit 1
fi

# Filesystem destruction (rm -rf on root or home)
if echo "$COMMAND" | grep -qE 'rm\s+-rf\s+(\/\s*$|~\s*$|\$HOME\s*$|\/\s+|~\s+|\$HOME\s+)'; then
  echo "BLOCKED: Destructive rm -rf on root or home directory detected." >&2
  exit 1
fi

# Permission escalation on root
if echo "$COMMAND" | grep -qE 'chmod\s+-R\s+777\s+\/'; then
  echo "BLOCKED: chmod -R 777 / detected." >&2
  exit 1
fi

# Fork bomb
if echo "$COMMAND" | grep -qF ':(){ :|:& };:'; then
  echo "BLOCKED: Fork bomb detected." >&2
  exit 1
fi

exit 0
