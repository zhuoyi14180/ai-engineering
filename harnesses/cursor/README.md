# Cursor Harness

将 AI 工程化体系的核心规范适配到 Cursor IDE 的配置格式。

## 包含内容

### Rules（`.cursor/rules/`）

| 文件 | 类型 | 说明 |
|------|------|------|
| `00-always.mdc` | Always | 沟通偏好、代码修改原则、测试约束、安全约束、编码偏好 |
| `01-coding-modes.mdc` | Agent Requested | 三模式工作规范（automated/spec-coding/vibe-coding） |
| `02-code-style.mdc` | Auto Attached（含 glob） | 各语言详细编码规范 |
| `03-security.mdc` | Agent Requested | 安全约束清单 |

### Skills（来自 `harnesses/shared/skills/`）

`make install-cursor` 会同时安装以下 skills 到 `.cursor/skills/`：

| Skill | 触发 | 说明 |
|-------|------|------|
| `commit` | `/commit` | 生成 conventional commit message |
| `review-pr` | `/review-pr` | 代码审查 |
| `init-project` | `/init-project` | 项目初始化 |
| `capture-idea` | `/capture-idea` | 想法 → feature-list.json |
| `update-context` | `/update-context` | 经验沉淀到 context 文件 |

## 安装

### 安装到指定项目

```bash
# 从仓库根目录
make install-cursor PROJECT_DIR=/path/to/your/project
```

生成：
```
/path/to/your/project/
├── .cursor/
│   ├── rules/
│   │   ├── 00-always.mdc
│   │   ├── 01-coding-modes.mdc
│   │   ├── 02-code-style.mdc
│   │   └── 03-security.mdc
│   └── skills/
│       ├── commit/SKILL.md
│       ├── review-pr/SKILL.md
│       ├── init-project/SKILL.md
│       ├── capture-idea/SKILL.md
│       └── update-context/SKILL.md
```

### 全局安装（Cursor 全局规则目录）

Cursor 支持全局规则，存放在 `~/.cursor/rules/`：

```bash
make install-cursor PROJECT_DIR=~/.cursor
# 注意：全局 rules 位于 ~/.cursor/rules/，但 skills 通常是项目级的
```

## 规则类型说明

Cursor Rules 有四种类型（通过 YAML frontmatter 控制）：

| 类型 | 配置 | 触发时机 |
|------|------|---------|
| **Always** | `alwaysApply: true` | 每次请求都加载 |
| **Auto Attached** | `globs: ["*.ts"]` | 打开匹配文件时自动加载 |
| **Agent Requested** | `description: "..."` | AI 根据任务描述自动判断是否加载 |
| **Manual** | 无特殊配置 | 用户在对话中输入 `@ruleName` 时加载 |

## 与 Claude Code 的对比

| 功能 | Claude Code | Cursor |
|------|------------|--------|
| 核心规范 | `CLAUDE.md` | `00-always.mdc`（Always 规则） |
| 工作模式 | 内置于 `CLAUDE.md` | `01-coding-modes.mdc`（Agent Requested） |
| Skills | `~/.claude/skills/` 全局 | `.cursor/skills/` 项目级 |
| Hooks（自动执行） | `hooks/` shell 脚本 | ❌ Cursor 无 hook 机制 |
| 安全规则 | `settings.json` deny + `pre-bash-check.sh` | `03-security.mdc`（指导原则） |

> **注意**：Cursor 没有 hooks 机制，因此无法像 Claude Code 那样自动拦截危险命令或格式化代码。安全约束以"指导原则"的形式存在于规则文件中，而非强制拦截。
