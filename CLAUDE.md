# AI Engineering System

本仓库是个人 AI 工程化体系，支持 Claude Code、Codex CLI、Cursor 三种 AI 工具，提供 auto-coding / spec-coding / vibe-coding 三种工作模式。

## 使用方式

- `make install-claude`：将 `harnesses/claude-code/` 同步到 `~/.claude/`
- `make install-codex`：将 `harnesses/codex/` 同步到 `~/.codex/` + `~/.agents/skills/`
- `make install-cursor PROJECT_DIR=<path>`：将 cursor harness 安装到指定项目
- `make diff`：查看 claude-code harness 与 `~/.claude/` 的差异

## 目录说明

- `harnesses/`：各 AI 工具的适配配置（claude-code / codex）
- `skills/`：可跨工具复用的技能（Claude Code、Codex、Cursor 共用同一份）
- `agents/`：Generator（coding.md）和 Evaluator（evaluator.md）的 prompt 规范
- `context/`：专题知识片段，可在任意 CLAUDE.md 中 `@import`
- `templates/`：新项目的起始文件模板
- `docs/`：方法论文档和 harness 审查记录

## 核心文件

- `harnesses/claude-code/CLAUDE.md`：个人全局偏好，最终部署到 `~/.claude/CLAUDE.md`
- `agents/coding.md`：Generator Agent 规范（auto / spec / vibe 三模式）
- `agents/evaluator.md`：Evaluator Agent 规范（独立 QA，通过 Agent tool 隔离上下文）
- `context/ai-engineering-principles.md`：Anthropic 文章方法论摘要
