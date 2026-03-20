# AI 工程化原则

本文件提炼自 Anthropic 工程博客 "Effective Harnesses for Long-Running Agents" 及 OpenAI 工程博客 "Harness Engineering"（2026-02），是本体系核心方法论的精华摘要。

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
- 浏览器自动化（如 Playwright）是端到端验证的有效工具

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

---

## 扩展原则（来自 OpenAI 工程实践，2026-02）

### 6. AGENTS.md 是目录，不是百科全书

AGENTS.md（或 CLAUDE.md）的职责是作为「目录」——短小、稳定、指向其他地方的信息。

- 长度控制在 100 行以内
- 内容是地图，不是手册：列出有哪些文档、各在哪、各管什么
- 真正的知识存放在 `docs/` 下的分层目录中
- 一个巨大的指令文件会挤掉任务上下文，且无法验证时效性

推荐的项目知识结构：

```
CLAUDE.md            ← 目录 + 地图（100 行以内）
ARCHITECTURE.md      ← 域和包的顶层地图
docs/
├── design-docs/     ← 架构设计决策（带验证状态）
├── exec-plans/      ← 活跃任务计划（active/ 和 completed/）
│   └── tech-debt-tracker.md
└── references/      ← 第三方 llms.txt 等只读参考
```

### 7. Agent 可读性优先于人类可读性

从 Agent 的视角来看，**它在运行时无法在上下文中访问的任何内容都是不存在的**。

- Google Docs、Slack 记录、口头约定、人脑中的设计决策——对 Agent 来说都不存在
- 只有已提交到仓库的、版本化的工件（代码、Markdown、JSON schema、可执行计划）才是 Agent 能推理的现实
- 「好的人类文档」与「Agent 可推理的文档」不是同一件事：Agent 文档需要明确、完整、自洽、可引用，不依赖隐含约定

**实践推论**：
- 每次架构决策都必须落成 ADR（Architecture Decision Record），否则对 Agent 不存在
- 团队达成的规范若只在 Slack 里，应迁移到仓库 Markdown 文件
- 任何「只有人知道」的上下文，都是技术债

### 8. 熵管理：持续的「代码垃圾回收」

AI 会复现代码库中已存在的模式，包括不理想的模式。随着 Agent 写入量增大，熵不可避免地积累。

解法不是人工定期清理（不可扩展），而是将「品味」编码为可机械执行的规则：

- 定义「黄金原则（Golden Principles）」：带主观意见的机械规则，保持代码库对未来 Agent 运行的可读性和一致性
- 周期性运行 Gardener Agent：扫描偏差、更新质量评分、发起有针对性的重构 PR
- 将 code review 中的人工反馈、重构 PR 都转化为文档更新或 linter 规则，使其持续生效

技术债就像高息贷款：以小额方式持续偿还，优于积累后一次性解决。
