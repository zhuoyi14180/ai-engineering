# MCP 推荐配置

MCP（Model Context Protocol）允许 Claude Code 连接外部工具和数据源。以下是推荐的 MCP 服务器及配置命令。

## 安装命令

```bash
# 以下命令中 'claude' 为默认命令名，如使用其他名称（如 claude-internal）请替换
# 文件系统 MCP（允许访问特定目录）
claude mcp add filesystem -- npx -y @modelcontextprotocol/server-filesystem /path/to/allowed/dir

# Playwright 浏览器自动化（E2E 测试、网页操作）
claude mcp add playwright -- npx @playwright/mcp@latest

# 数据库 MCP（SQLite）
claude mcp add sqlite -- npx -y @modelcontextprotocol/server-sqlite /path/to/db.sqlite

# GitHub MCP（PR 管理、Issue 操作）
claude mcp add github -- npx -y @modelcontextprotocol/server-github
# 需要设置 GITHUB_PERSONAL_ACCESS_TOKEN 环境变量
```

## 推荐 MCP 列表

| MCP | 用途 | 安装包 |
|-----|------|--------|
| filesystem | 文件读写（受限目录） | `@modelcontextprotocol/server-filesystem` |
| playwright | 浏览器自动化、E2E 测试 | `@playwright/mcp` |
| github | GitHub 操作（PR/Issue） | `@modelcontextprotocol/server-github` |
| sqlite | SQLite 数据库操作 | `@modelcontextprotocol/server-sqlite` |

## Playwright MCP 使用场景

对应 Anthropic 文章中的「浏览器自动化验证」：

```
# 在 Claude Code 中，Playwright MCP 安装后可以：
- 打开页面验证功能
- 截图对比
- 模拟用户交互
- 验收测试（E2E）
```

## 查看已安装的 MCP

```bash
claude mcp list
```

## 注意事项

- MCP 配置存储在 `~/.claude/` 中（用户级）或项目的 `.claude/` 中（项目级）
- 敏感的 MCP（如 GitHub）需要环境变量，不要将 token 硬编码
- 项目级 MCP 优先于用户级
