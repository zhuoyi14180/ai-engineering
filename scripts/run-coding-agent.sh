#!/usr/bin/env bash
# run-coding-agent.sh — 驱动 Coding Agent 在目标项目中循环执行 feature 实现
#
# 用法：
#   ./scripts/run-coding-agent.sh [OPTIONS]
#
# 选项：
#   --max-runs N           最大迭代次数（默认不限，运行直到所有 feature 完成）
#   --project-dir PATH     目标项目路径（默认当前目录）
#   --timeout-per-run N    每轮 claude 调用的超时秒数（默认不限）
#   --skip-permissions     向 claude 传递 --dangerously-skip-permissions
#                          警告：会跳过所有工具调用确认，请确认项目已配置安全约束
#
# 前置要求：
#   - 目标项目根目录存在 feature-list.json 和 progress.json
#   - claude CLI 已安装且在 PATH 中
#
# 环境变量：
#   CLAUDE_CMD             Claude CLI 命令名或路径（默认 claude）
#   NOTIFY_CMD             失败时执行的通知命令（可选，如 "osascript -e 'display notification...'")
#                          脚本会在命令后追加一个消息参数，例：
#                            NOTIFY_CMD='notify-send "Coding Agent"' ./run-coding-agent.sh ...

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_PROMPT="$SCRIPT_DIR/../agents/coding.md"

# ---------- 默认配置 ----------
MAX_RUNS=0
PROJECT_DIR="$(pwd)"
SKIP_PERMISSIONS=false
TIMEOUT_PER_RUN=0
CLAUDE_CMD="${CLAUDE_CMD:-claude}"

# ---------- 参数解析 ----------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --max-runs)
      MAX_RUNS="$2"; shift 2 ;;
    --project-dir)
      PROJECT_DIR="$(realpath "$2")"; shift 2 ;;
    --timeout-per-run)
      TIMEOUT_PER_RUN="$2"; shift 2 ;;
    --skip-permissions)
      SKIP_PERMISSIONS=true; shift ;;
    *)
      echo "Unknown option: $1" >&2
      echo "Usage: $0 [--max-runs N] [--project-dir PATH] [--timeout-per-run N] [--skip-permissions]" >&2
      exit 1 ;;
  esac
done

# ---------- 前置检查 ----------
if ! command -v "$CLAUDE_CMD" &>/dev/null; then
  echo "Error: '$CLAUDE_CMD' command not found. Install Claude Code first." >&2
  exit 1
fi

if [[ ! -f "$AGENT_PROMPT" ]]; then
  echo "Error: Coding Agent prompt not found at $AGENT_PROMPT" >&2
  exit 1
fi

if [[ ! -f "$PROJECT_DIR/feature-list.json" ]]; then
  echo "Error: $PROJECT_DIR/feature-list.json not found." >&2
  echo "Run 'init-project' skill first, or create feature-list.json from templates/feature-list.json." >&2
  exit 1
fi

if [[ ! -f "$PROJECT_DIR/progress.json" ]]; then
  echo "Error: $PROJECT_DIR/progress.json not found." >&2
  echo "Run 'init-project' skill first, or create progress.json from templates/progress.json." >&2
  exit 1
fi

# ---------- 日志目录 ----------
LOG_DIR="$PROJECT_DIR/auto-logs"
mkdir -p "$LOG_DIR"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
MAIN_LOG="$LOG_DIR/auto-$TIMESTAMP.log"

log() {
  local msg="[$(date +%H:%M:%S)] $*"
  echo "$msg"
  echo "$msg" >> "$MAIN_LOG"
}

# ---------- 辅助函数：统计 failing features ----------
count_failing() {
  grep -c '"status".*"failing"' "$PROJECT_DIR/feature-list.json" 2>/dev/null || echo 0
}

# ---------- 辅助函数：统计 blocked features ----------
count_blocked() {
  grep -c '"status".*"blocked"' "$PROJECT_DIR/feature-list.json" 2>/dev/null || echo 0
}

# ---------- 构造 claude 调用参数 ----------
CLAUDE_ARGS=("-p")
CLAUDE_ARGS+=("--allowedTools" "Bash,Edit,Read,Write,Glob,Grep,WebFetch,WebSearch,NotebookEdit,Task")
if [[ "$SKIP_PERMISSIONS" == true ]]; then
  CLAUDE_ARGS+=("--dangerously-skip-permissions")
fi

# ---------- 主流程 ----------
INITIAL_FAILING="$(count_failing)"
log "=== Coding Agent Automation ==="
log "Project: $PROJECT_DIR"
log "Max runs: $([[ "$MAX_RUNS" -eq 0 ]] && echo unlimited || echo "$MAX_RUNS")"
log "Timeout per run: $([[ "$TIMEOUT_PER_RUN" -eq 0 ]] && echo unlimited || echo "${TIMEOUT_PER_RUN}s")"
log "Skip permissions: $SKIP_PERMISSIONS"
log "Initial failing features: $INITIAL_FAILING"
log ""

if [[ "$INITIAL_FAILING" -eq 0 ]]; then
  log "All features already passing. Nothing to do."
  exit 0
fi

TOTAL_COMPLETED=0
PROMPT_FILE=""
trap '[[ -n "$PROMPT_FILE" ]] && rm -f "$PROMPT_FILE"' EXIT

run=0

while true; do
  REMAINING="$(count_failing)"

  if [[ "$REMAINING" -eq 0 ]]; then
    BLOCKED="$(count_blocked)"
    if [[ "$BLOCKED" -gt 0 ]]; then
      log "$BLOCKED feature(s) blocked — Planner intervention failed. Human review required."
      log "Check feature-list.json for blocked features and their notes."
      if [[ -n "${NOTIFY_CMD:-}" ]]; then
        eval "$NOTIFY_CMD" "Coding Agent stopped: $BLOCKED feature(s) blocked in $(basename "$PROJECT_DIR")" 2>/dev/null || true
      fi
      exit 1
    fi
    log "All features passing. Stopping after $run runs."
    break
  fi

  if [[ "$MAX_RUNS" -gt 0 && "$run" -ge "$MAX_RUNS" ]]; then
    log "Reached max runs ($MAX_RUNS). Stopping."
    break
  fi

  run=$((run + 1))
  log "--- Run $run${MAX_RUNS:+/$MAX_RUNS} | Remaining: $REMAINING failing features ---"
  RUN_LOG="$LOG_DIR/run-$run-$TIMESTAMP.log"

  # 构造本次 prompt：复用 Coding Agent prompt + 自动化附加指令
  PROMPT_FILE="$(mktemp)"
  cat > "$PROMPT_FILE" << PROMPT_EOF
$(cat "$AGENT_PROMPT")

---

## 自动化模式

工作目录：$PROJECT_DIR

此次为非交互式自动化会话：
- 请先 cd "$PROJECT_DIR"，再按会话开始检查清单执行
- 跳过"向用户确认"步骤，确认状态后直接开始实现
- 完成一个 feature 后立即结束会话
PROMPT_EOF

  # 执行 claude（可选超时）
  EXIT_CODE=0
  if [[ "$TIMEOUT_PER_RUN" -gt 0 ]]; then
    timeout "$TIMEOUT_PER_RUN" "$CLAUDE_CMD" "${CLAUDE_ARGS[@]}" < "$PROMPT_FILE" 2>&1 | tee "$RUN_LOG" || EXIT_CODE=$?
    if [[ $EXIT_CODE -eq 124 ]]; then
      log "Run $run timed out after ${TIMEOUT_PER_RUN}s"
    fi
  else
    "$CLAUDE_CMD" "${CLAUDE_ARGS[@]}" < "$PROMPT_FILE" 2>&1 | tee "$RUN_LOG" || EXIT_CODE=$?
  fi

  rm -f "$PROMPT_FILE"; PROMPT_FILE=""

  REMAINING_AFTER="$(count_failing)"
  COMPLETED_THIS_RUN="$((REMAINING - REMAINING_AFTER))"
  TOTAL_COMPLETED="$((TOTAL_COMPLETED + COMPLETED_THIS_RUN))"

  if [[ $EXIT_CODE -ne 0 ]]; then
    log "Run $run exited with code $EXIT_CODE (see $RUN_LOG)"
  fi

  log "Run $run done: completed $COMPLETED_THIS_RUN feature(s), $REMAINING_AFTER remaining"
  log "Log: $RUN_LOG"
  log ""

  sleep 2
done

# ---------- 最终汇总 ----------
FINAL_REMAINING="$(count_failing)"
FINAL_BLOCKED="$(count_blocked)"
log "=== Summary ==="
log "Total runs:      $run"
log "Completed:       $TOTAL_COMPLETED feature(s)"
log "Still failing:   $FINAL_REMAINING feature(s)"
log "Blocked:         $FINAL_BLOCKED feature(s)"
log "Main log:        $MAIN_LOG"

if [[ "$FINAL_REMAINING" -gt 0 ]]; then
  log ""
  log "Some features still failing. Check progress.json for blockers."
  # 触发通知（如果配置了 NOTIFY_CMD）
  if [[ -n "${NOTIFY_CMD:-}" ]]; then
    eval "$NOTIFY_CMD" "Coding Agent stopped: $FINAL_REMAINING feature(s) still failing in $(basename "$PROJECT_DIR")" 2>/dev/null || true
  fi
  exit 1
fi
