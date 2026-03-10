# Anthropic 工程实践精华摘录

原文：[Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)

---

## 核心论点

> AI agents struggle with multi-session tasks because "each new session begins with no memory of what came before."

解法不是让模型更聪明，而是**设计好 harness**——让 agent 在失忆的情况下依然有效工作。

---

## 双 Agent 架构

### Initializer Agent
- 设置完整开发环境
- 创建 `init.sh`（环境初始化脚本）
- 建立 `claude-progress.txt`（或 JSON）
- 做初始 git commit 建立基线

### Coding Agent
- 跨多个会话增量工作
- 每次结束留下「干净状态」供下次接手
- 聚焦于单个功能的完整实现

---

## 关键设计决策

### 1. 用 JSON，不用 Markdown

> "JSON file format preferred over Markdown for better model compliance"

模型对 JSON 结构的遵循率高于 Markdown checklist。功能列表用 JSON，包含 200+ 个详细需求，初始状态均为 "failing"。

### 2. Git 是唯一可信的进度记录

> "Git history serves as authoritative progress record"

- 每个有意义的进展对应一个 commit
- Progress 文件提供会话间的连续性
- Commit 是离散的进度标记

### 3. 测试是不可协商的约束

> "It is unacceptable to remove or edit tests because this could lead to missing or buggy functionality"

- 浏览器自动化（Puppeteer）用于端到端验证
- 不允许删除测试或修改 assertion
- 新功能必须先通过测试验证

### 4. 会话开始状态验证

每个 Coding Agent 会话必须：
1. 检查当前目录
2. 读取 git log
3. 读取 progress 文件
4. 验证基础功能可用

### 5. 一次一个功能

> "Agents work on one feature at a time"

完成一个功能，标记 passing，commit，再开始下一个。不并行、不跳跃。

---

## 故障模式与预防

| 故障模式 | 预防方式 |
|---------|---------|
| 过早声明完成 | 结构化功能追踪（JSON 状态） |
| 环境问题 | Git history + progress 文档 |
| 测试覆盖缺口 | 浏览器自动化 + 明确的 prompt 约束 |
| 回归问题 | 每次会话运行完整测试套件 |

---

## 工具推荐

- **Git**：版本控制 + 状态管理
- **JSON**：结构化数据表示
- **Puppeteer/Playwright MCP**：浏览器自动化测试
- **Shell scripts**：环境初始化（init.sh）
