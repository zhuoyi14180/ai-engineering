# AI 工具使用模式

当 Claude Code 可以选择多种工具实现相同目标时，应优先使用专用工具而非通用 Bash。以下是选择原则和常见模式。

## 工具选择决策树

```
需要读取文件内容？
  → 已知确切路径     → Read（不用 bash cat）
  → 需要按路径模式查找 → Glob（不用 bash find）
  → 需要按内容搜索   → Grep（不用 bash grep/rg）
  → 跨多文件研究     → Agent/Explore subagent

需要执行操作？
  → 格式化、安装、运行测试 → Bash（合理）
  → git 操作             → Bash（合理）
  → 文件编辑             → Edit / Write（不用 bash sed/awk）
```

## 避免的模式

| 不推荐 | 推荐 | 原因 |
|--------|------|------|
| `bash cat file.py` | `Read file.py` | Read 有权限控制，结果格式化更好 |
| `bash find . -name "*.ts"` | `Glob **/*.ts` | Glob 性能更好，不需要 shell 权限 |
| `bash grep -r "pattern" .` | `Grep pattern` | Grep 有更好的过滤和输出控制 |
| `bash echo "content" > file` | `Write file` | Write 有清晰的权限提示 |
| `bash sed -i 's/old/new/g' file` | `Edit file` | Edit 显示精确 diff，更可审计 |

## MCP 使用场景

MCP 服务器扩展了 Claude 的工具边界，在以下场景比 Bash 更合适：

### Playwright MCP（浏览器自动化）
- **何时用**：需要验证 Web UI 行为、运行 E2E 测试、截图对比
- **不适用**：只需要检查 API 响应（用 Bash curl 即可）
- 安装参考：`mcps/README.md`

### filesystem MCP
- **何时用**：需要访问 Claude Code 工作目录以外的文件（如 `~/Documents`）
- **不适用**：项目目录内的文件（Read/Edit/Write 工具已覆盖）

### github MCP
- **何时用**：管理 PR、Issue、Review（比 gh CLI 更结构化）
- **不适用**：本地 git 操作（Bash git 命令更直接）

### sqlite MCP
- **何时用**：项目使用 SQLite，需要直接查询数据库验证数据
- **不适用**：读取 JSON/CSV 数据文件（Read 工具足够）

## 自动化模式下的工具选择

在 `run-coding-agent.sh` 驱动的自动化模式下：
- 优先使用非交互工具（Read、Grep、Glob），减少不必要的 Bash 调用
- Bash 调用会经过 `pre-bash-check.sh` 安全检查，频繁调用会增加延迟
- 避免在循环中使用 Bash（改用 Glob + 代码逻辑）

## 使用 Agent/Explore Subagent

当需要跨多个文件或不确定目标位置时，使用 Explore subagent 比手动 Grep + Read 组合更高效：
- 需要理解某个功能的完整实现路径
- 搜索关键词可能匹配多个不相关位置
- 需要在多个文件中建立关联

不要用 Agent 完成单个文件的读取或简单的关键词搜索。
