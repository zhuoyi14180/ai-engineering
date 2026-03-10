# AI Engineering System

本仓库是个人 AI 工程化体系，提供可跨项目复用的 Claude Code 配置。

## 使用方式

- `make install`：将 `global/` 同步到 `~/.claude/`
- `make diff`：查看与当前 `~/.claude/` 的差异

## 目录说明

- `global/`：映射到 `~/.claude/` 的内容（CLAUDE.md、settings.json、hooks、skills）
- `context/`：专题知识片段，可在任意 CLAUDE.md 中 `@import`
- `agents/`：Initializer Agent 和 Coding Agent 的 prompt 定义
- `templates/`：新项目的起始文件模板
- `docs/`：方法论文档

## 核心文件

- `global/CLAUDE.md`：个人全局偏好，最终部署到 `~/.claude/CLAUDE.md`
- `context/ai-engineering-principles.md`：Anthropic 文章方法论摘要
- `agents/coding/prompt.md`：长期任务 Coding Agent 的会话规范
