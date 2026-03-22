#!/usr/bin/env bash
# build-harnesses.sh
# Renders harnesses/shared/coding-agent.md.template to each tool's agent spec:
#   - agents/coding/prompt.md            (Claude Code)
#   - harnesses/codex/AGENTS.md          (Codex CLI)
#   - harnesses/cursor/rules/01-coding-modes.mdc  (Cursor)
#
# Usage: bash scripts/build-harnesses.sh
# Run from the repo root.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE="$REPO_ROOT/harnesses/shared/coding-agent.md.template"

if [[ ! -f "$TEMPLATE" ]]; then
  echo "ERROR: template not found: $TEMPLATE" >&2
  exit 1
fi

# ── sed-based render ──────────────────────────────────────────────────────────
# render <output_file> key=value ...
# Replaces {{KEY}} in template with value, writes to output_file.
render() {
  local output_file="$1"; shift
  local content
  content="$(cat "$TEMPLATE")"

  for kv in "$@"; do
    local key="${kv%%=*}"
    # Use printf to handle newlines in value; escape | for sed delimiter
    local raw_val="${kv#*=}"
    # Replace newlines with \n literal for sed, escape | and &
    local val
    val="$(printf '%s' "$raw_val" | sed 's/\\/\\\\/g; s/|/\\|/g; s/&/\\&/g; s/$/\\n/' | tr -d '\n' | sed 's/\\n$//')"
    content="$(echo "$content" | sed "s|{{${key}}}|${val}|g")"
  done

  # Warn about any unreplaced placeholders
  if echo "$content" | grep -qE '\{\{[A-Z_]+\}\}'; then
    echo "  WARNING: unreplaced placeholders in $output_file:" >&2
    echo "$content" | grep -oE '\{\{[A-Z_]+\}\}' | sort -u | sed 's/^/    /' >&2
  fi

  mkdir -p "$(dirname "$output_file")"
  printf '%s\n' "$content" > "$output_file"
  echo "  [OK] ${output_file#"$REPO_ROOT/"}"
}

# ── Claude Code → agents/coding/prompt.md ────────────────────────────────────
echo "Building Claude Code agent spec..."
render "$REPO_ROOT/agents/coding/prompt.md" \
  "TOOL_NAME=Claude Code" \
  "SLASH_COMMIT=/commit" \
  "SLASH_CAPTURE_IDEA=/capture-idea" \
  "UPDATE_CONTEXT_INSTRUCTION=运行 \`/update-context\`" \
  "COMMIT_INSTRUCTION_AUTOMATED=\`\`\`bash
git add .
git commit -m \"feat(<scope>): <功能描述> [progress: X/N features]\"
\`\`\`" \
  "COMMIT_INSTRUCTION_SESSION_END=运行 \`/commit\` 或手动执行 git commit"

# ── Codex CLI → harnesses/codex/AGENTS.md ────────────────────────────────────
echo "Building Codex CLI agent spec..."
mkdir -p "$REPO_ROOT/harnesses/codex"
render "$REPO_ROOT/harnesses/codex/AGENTS.md" \
  "TOOL_NAME=Codex CLI" \
  "SLASH_COMMIT=/commit skill（或手动：分析变更 → 生成 conventional commit message → 运行 git commit）" \
  "SLASH_CAPTURE_IDEA=/capture-idea skill（或手动生成 feature-list.json）" \
  "UPDATE_CONTEXT_INSTRUCTION=将本次发现提炼为对应 context/ 文件中的新条目（参考 harnesses/shared/skills/update-context/SKILL.md）" \
  "COMMIT_INSTRUCTION_AUTOMATED=\`\`\`bash
git add .
git commit -m \"feat(<scope>): <功能描述> [progress: X/N features]\"
\`\`\`" \
  "COMMIT_INSTRUCTION_SESSION_END=执行 git add + git commit，message 遵循 conventional commits 格式"

# ── Cursor → harnesses/cursor/rules/01-coding-modes.mdc ──────────────────────
echo "Building Cursor rules (01-coding-modes.mdc)..."

CURSOR_RULES_DIR="$REPO_ROOT/harnesses/cursor/rules"
mkdir -p "$CURSOR_RULES_DIR"

REPO_ROOT="$REPO_ROOT" python3 - <<'PYEOF'
import os, sys

repo_root = os.environ['REPO_ROOT']
template_path = os.path.join(repo_root, 'harnesses/shared/coding-agent.md.template')
output_path = os.path.join(repo_root, 'harnesses/cursor/rules/01-coding-modes.mdc')

with open(template_path, 'r') as f:
    content = f.read()

replacements = {
    '{{TOOL_NAME}}': 'Cursor',
    '{{SLASH_COMMIT}}': '`/commit` skill（或手动执行 git commit）',
    '{{SLASH_CAPTURE_IDEA}}': '`/capture-idea` skill',
    '{{UPDATE_CONTEXT_INSTRUCTION}}': '运行 `/update-context` skill',
    '{{COMMIT_INSTRUCTION_AUTOMATED}}': '```bash\ngit add .\ngit commit -m "feat(<scope>): <功能描述> [progress: X/N features]"\n```',
    '{{COMMIT_INSTRUCTION_SESSION_END}}': '执行 git add + git commit，message 遵循 conventional commits 格式',
}
for k, v in replacements.items():
    content = content.replace(k, v)

# Extract mode detection + three modes sections (stop before context management)
start_marker = '## 第一步：检测工作模式'
ctx_marker = '## 上下文管理规则'
start_idx = content.find(start_marker)
ctx_idx = content.find(ctx_marker)

if start_idx == -1:
    print('ERROR: mode detection section not found', file=sys.stderr)
    sys.exit(1)

end_idx = ctx_idx if ctx_idx != -1 and ctx_idx > start_idx else len(content)
modes_content = content[start_idx:end_idx].strip()

frontmatter = (
    '---\n'
    'description: "项目工作模式检测：通过 feature-list.json 和 progress.json 判断工作模式'
    '（automated/spec-coding/vibe-coding）。当用户开始新项目、询问工作流程、'
    '或提及 feature-list / progress.json 时应用此规则。"\n'
    'alwaysApply: false\n'
    '---\n\n'
)

with open(output_path, 'w') as f:
    f.write(frontmatter + modes_content + '\n')

print(f'  [OK] harnesses/cursor/rules/01-coding-modes.mdc')
PYEOF

echo ""
echo "Build complete."
