# AI Engineering System

个人 AI 工程化体系，构建「开发 → 验证 → 沉淀」的闭环工作流。支持 Claude Code、Codex CLI、Cursor 三种 AI 工具，以及 auto-coding / spec-coding / vibe-coding 三种工作模式。

核心理念来自 Anthropic 工程博客 [Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) 和 [Harness Design for Long-Running Application Development](https://www.anthropic.com/engineering/harness-design-long-running-apps)。

## 快速开始

```bash
# Claude Code（安装到 ~/.claude/）
make install-claude

# Codex CLI（先生成 AGENTS.md，再安装到 ~/.codex/ + ~/.agents/skills/）
make install-codex

# Cursor（安装 skills/agents 到 ~/.cursor/）
make install-cursor

# 查看 claude-code harness 与 ~/.claude/ 的差异
make diff
```

## 三种工作模式

系统通过文件存在性自动检测，无需手动配置：

| 条件 | 模式 | 适用场景 |
|------|------|---------|
| `progress.json` + `feature-list.json` 同时存在 | **auto-coding** | 脚本驱动，无人值守，严格约束 |
| 只有 `feature-list.json` 存在 | **spec-coding** | 结构化交互，commit 由开发者控制 |
| 两者都不存在 | **vibe-coding** | 随意探索，无预设结构 |

## 三 Agent 架构

```
Planner Agent         → 初始化 feature-list.json；blocked 时自动重规划
Coding Agent          → 增量实现功能，完成后改 status 为 eval_pending
  └── Agent tool 调用 →
Evaluator Agent       → 独立上下文验证，通过 → passing，失败 → fail 退回修复
  └── retry > 3 时 →
Planner Agent         → 诊断根因，尝试拆分 feature；无法拆分时通知人工介入
```

**关键设计**：Evaluator 通过 Claude Code 的 Agent tool 调用，看不到 Generator 的执行历史，避免自评偏差。Planner 是唯一可以修改 `acceptance_criteria` 和 `replanned` 字段的角色。

> `/init-project` skill 负责搭建项目环境，调用 Planner Agent 生成 feature-list.json。

## feature-list.json 状态机

```
failing ←──── fail ──── eval_pending ──→ passing
   ↑                          │
   │               retry > 3  ↓
   │                       blocked
   │                          │
   │               replanned = false?
   │               ↙               ↘
   │       Planner 介入         replanned = true
   │       ↙         ↘           → 停止，通知人工
   │   拆分成功     无法拆分
   │  删原 feature → replanned = true
   │  插子 feature → 停止，通知人工
   │  (replanned=true)
   └── 子 feature 进入正常循环
```

## 目录结构

```
ai-engineering/
├── agents/
│   ├── planner.md                  ← Planner Agent 规范（初始分解 + blocked 恢复）
│   ├── coding.md                   ← Coding Agent (Generator) 规范
│   └── evaluator.md                ← Evaluator Agent (QA) 规范
│
├── skills/                         ← 三工具通用 (SKILL.md 格式一致)
│   ├── commit/
│   ├── init-project/
│   ├── capture-idea/
│   ├── review-pr/
│   ├── update-context/
│   └── ai-engineering-digest/
│
├── context/                        ← 可 @import 的知识模块
│   ├── ai-engineering-principles.md
│   ├── coding-standards.md
│   ├── git-workflow.md
│   ├── testing-patterns.md
│   ├── security-checklist.md
│   └── evaluation-rubrics.md
│
├── templates/                      ← 新项目起始文件
│   ├── feature-list.json           ← 含 eval_report schema
│   ├── progress.json
│   ├── CLAUDE.md                   ← 项目级配置模板
│   ├── design-doc.md
│   └── adr.md
│
├── harnesses/
│   ├── claude-code/                ← 部署到 ~/.claude/
│   │   ├── CLAUDE.md               ← 全局个人偏好（唯一来源）
│   │   ├── settings.json
│   │   └── hooks/
│   │       ├── pre-bash-check.sh
│   │       ├── post-edit-format.sh
│   │       └── stop-session-check.sh
│   └── codex/                      ← 部署到 ~/.codex/
│       ├── AGENTS.md               ← 由 make build 从 CLAUDE.md 生成
│       └── config.toml
│
├── scripts/
│   ├── run-coding-agent.sh         ← auto-coding 自动化循环
│   └── build.py                    ← 生成 codex/AGENTS.md
│
├── docs/
│   ├── methodology.md
│   ├── setup-guide.md
│   └── harness-audit.md            ← 组件假设登记表
│
├── evals/skills/                   ← Skill 质量评估用例
└── Makefile
```

## 各工具部署映射

| 内容 | Claude Code | Codex | Cursor |
|------|-------------|-------|--------|
| 全局偏好 | `~/.claude/CLAUDE.md` | `~/.codex/AGENTS.md`（生成） | GUI Settings（手动） |
| 项目规范 | `<project>/CLAUDE.md` | `<project>/AGENTS.md` | `<project>/AGENTS.md` |
| Skills | `~/.claude/skills/` | `~/.agents/skills/` | `~/.cursor/skills/` |
| Agents | `~/.claude/agents/` | `~/.codex/agents/` | `~/.cursor/agents/` |
| Hooks | `settings.json` |  `.rules` | 无 |

## 接入新项目

```bash
# 方式一：git submodule
git submodule add https://github.com/<user>/ai-engineering .ai-engineering

# 方式二：复制模板
cp .ai-engineering/templates/CLAUDE.md ./CLAUDE.md
cp .ai-engineering/templates/feature-list.json ./feature-list.json
cp .ai-engineering/templates/progress.json ./progress.json
```

项目 CLAUDE.md 中按需引用：
```
@.ai-engineering/context/coding-standards.md
@.ai-engineering/context/git-workflow.md
@.ai-engineering/context/testing-patterns.md
@.ai-engineering/context/security-checklist.md
```

## 自动化脚本运行

```bash
./scripts/run-coding-agent.sh \
  --project-dir /path/to/project \
  --max-runs 10 \
  --timeout-per-run 300
```

脚本循环调用 Coding Agent（含内嵌的 Evaluator 和 Planner），直到所有 features 变为 passing 或存在无法恢复的 blocked feature。
