# AI 工程化原则

本文件提炼自 Anthropic 工程博客 "Effective Harnesses for Long-Running Agents"，是本体系核心方法论的精华摘要。

## 核心问题：Agent 的失忆本质是工程问题

每个新会话都从零开始，没有上一次的记忆。这不是模型能力问题，而是工程设计问题。
解法是构建好的 **harness**——让 agent 能在失忆的情况下依然有效工作。

## 双 Agent 模式

### Initializer Agent（初始化）
- 负责：搭建环境、建立基线、创建 `progress.json`、做初始 git commit
- 运行时机：新项目启动时，或环境损坏需要重置时
- 产出：干净的环境状态 + 可被 Coding Agent 接手的起点

### Coding Agent（开发）
- 负责：增量实现功能、更新进度、维护测试、做 git commit
- 每次会话开始时必须：读取 git log、读取 progress.json、验证基础功能可用
- 每次会话结束时必须：更新 progress.json、做 commit、留下清晰的下一步说明

## 关键设计原则

### 1. 进度文件（progress.json）是必需品，不是可选项

长期任务必须维护结构化进度文件。它是唯一跨会话的「记忆」，是 agent 之间交接的依据。
- 使用 JSON 格式（比 Markdown 有更高的模型遵循率）
- 每完成一个功能立即更新，不攒到最后

### 2. Git 是状态机

每个有意义的进展对应一个 commit。git log 就是任务执行历史。
- 没有 commit = 没有证据 = 不可信
- 可以通过 git bisect 等工具快速定位回退点

### 3. 测试是不可协商的约束

> "It is unacceptable to remove or edit tests because this could lead to missing or buggy functionality."

- 测试失败时，修复代码；不修改 assertion 来让测试通过
- 浏览器自动化（如 Puppeteer）是端到端验证的有效工具

### 4. 功能列表用 JSON，不用 Markdown

JSON 格式的功能列表比 Markdown checklist 有更高的模型遵循率。
每个功能条目包含：名称、状态（failing/passing）、验收标准。

### 5. 一次只做一件事

Agent 每次会话聚焦于单个功能的完整实现和验证，不要跨功能并行。
完成一个，标记 passing，commit，再开始下一个。

## 闭环的三个阶段

```
开发  →  纠错  →  沉淀
```

- **开发**：Coding Agent 按 feature-list.json 逐项实现
- **纠错**：自动化测试 + 人工 review + evals 检验
- **沉淀**：将经验写入 context/ 文件，供后续项目 @import 复用

## 会话开始检查清单

```
□ 确认当前工作目录
□ git log --oneline -10（了解最近进展）
□ cat progress.json（了解当前状态和下一步）
□ 验证基础功能可用（运行一个核心测试）
□ 选择下一个 failing 的功能开始实现
```

## 会话结束检查清单

```
□ 更新 progress.json（标记本次完成的功能为 passing）
□ 运行完整测试套件，确保无回归
□ git commit（包含清晰的说明）
□ 在 progress.json 的 next_steps 字段写下下一步计划
```
