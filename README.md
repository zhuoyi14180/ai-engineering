# AI Engineering System

个人 AI 工程化体系，构建「开发 → 纠错 → 沉淀」的闭环工作流。支持三种工作模式，以及 Claude Code、Codex CLI、Cursor 三种 AI 工具。

## 快速开始

```bash
# Claude Code（安装到 ~/.claude/）
make install-claude

# Codex CLI（安装到 ~/.codex/ + ~/.agents/skills/）
make install-codex

# Cursor（安装到指定项目）
make install-cursor PROJECT_DIR=/path/to/project

# 查看 claude-code harness 与 ~/.claude/ 的差异
make diff
```

## 三种工作模式

系统通过文件存在性自动检测工作模式，无需手动配置：

| 条件 | 模式 | 适用场景 |
|------|------|---------|
| `progress.json` + `feature-list.json` 同时存在 | **automated** | 脚本驱动，无人值守，严格约束 |
| 只有 `feature-list.json` 存在 | **spec-coding** | 结构化交互，commit 由开发者决定 |
| 两者都不存在 | **vibe-coding** | 随意探索，无预设结构，无 commit 约束 |

### 模式 A：Automated（非交互自动化）

适用于长时间无人值守的批量功能实现。

```bash
# 驱动 Coding Agent 循环实现所有 failing features
./scripts/run-coding-agent.sh --project-dir /path/to/project

# 限制轮数 + 超时保护
./scripts/run-coding-agent.sh --max-runs 5 --timeout-per-run 300

# 失败时触发通知（macOS）
NOTIFY_CMD='osascript -e "display notification"' ./scripts/run-coding-agent.sh ...
```

**行为约束**：每完成一个 feature 立即 commit；会话结束时若有未 commit 变更，Stop hook 会阻断并提示。

### 模式 B：Spec-Coding（结构化交互）

适用于有设计文档和功能列表的有计划开发。

```
# 初始化新项目（搭建环境 + 生成 feature-list.json）
/init-project <项目描述>

# 或者只生成 feature-list.json（不搭建环境）
/capture-idea <想法描述>
```

**行为约束**：实现功能后更新 feature-list.json 状态，但不主动 commit；commit 时机完全由开发者决定。

### 模式 C：Vibe-Coding（自由探索）

适用于从模糊想法开始的快速探索。

```
# 从粗糙想法生成 spec 草稿（可选，会将下次会话切换为 spec-coding）
/capture-idea <你的想法>

# 或者直接开始对话
"我想实现一个 X 功能..."
```

**行为约束**：不提 progress.json，不建议 commit，不强制任何结构。

---

## 体系结构

```
ai-engineering/
├── harnesses/                   # AI 工具适配层
│   ├── shared/                  # 三工具共用（单一维护源）
│   │   ├── coding-agent.md.template  # 核心 Agent 规范模板（工具无关）
│   │   └── skills/              # 共用 skills（commit/review-pr/init-project/...)
│   ├── claude-code/             # Claude Code 配置（→ ~/.claude/）
│   │   ├── CLAUDE.md            # 个人偏好、三模式工作规范
│   │   ├── settings.json        # hooks、权限配置
│   │   ├── hooks/               # pre-bash-check / post-edit-format / stop-session-check
│   │   └── skills/              # Claude Code 专有 skills（ai-engineering-digest 等）
│   ├── codex/                   # Codex CLI 配置（→ ~/.codex/）
│   │   ├── AGENTS.md            # Coding Agent 规范（从模板渲染）
│   │   ├── config.toml          # 模型、审批策略配置
│   │   └── rules/default.rules  # Starlark 安全规则
│   └── cursor/                  # Cursor 配置（→ <project>/.cursor/）
│       └── rules/               # 00-always / 01-coding-modes / 02-code-style / 03-security
├── context/                     # 可复用专题知识片段（供 @import）
│   ├── ai-engineering-principles.md
│   ├── coding-standards.md
│   ├── testing-patterns.md
│   ├── git-workflow.md
│   ├── security-checklist.md
│   └── ai-tool-patterns.md
├── agents/
│   └── coding/prompt.md         # Coding Agent（支持三模式分支）
├── templates/                   # 新项目模板文件
│   ├── project-CLAUDE.md
│   ├── feature-list.json
│   ├── progress.json
│   ├── design-doc.md
│   └── adr.md
├── docs/                        # 方法论文档
├── evals/                       # Skill 质量评估用例
├── scripts/
│   ├── run-coding-agent.sh      # Automated 模式驱动脚本
│   └── build-harnesses.sh       # 从 shared/ 模板渲染各 harness 配置
└── mcps/                        # MCP 推荐配置
```

## 在新项目中使用

```bash
# 以子模块方式引入
git submodule add https://github.com/<user>/ai-engineering .ai-engineering

# 在项目 CLAUDE.md 中引用（按需选择）
# @.ai-engineering/context/coding-standards.md
# @.ai-engineering/context/testing-patterns.md
```

详见 [docs/setup-guide.md](docs/setup-guide.md)。

## 核心理念

- **三模式感知**：automated / spec-coding / vibe-coding 自动检测，约束随模式差异化
- **多工具支持**：claude-code / codex / cursor 共用核心规范，各自适配工具机制
- **流程闭环**：开发（Coding Agent）→ 纠错（hooks + review-pr + evals）→ 沉淀（update-context）
- **配置分层**：`~/.claude/CLAUDE.md`（个人全局）→ 项目 `CLAUDE.md`（项目上下文）→ `progress.json`（任务状态）
- **最小改动原则**：只做被要求的，不预判未来需求
