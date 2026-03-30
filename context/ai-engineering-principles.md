# AI 工程化原则

本文件提炼自 Anthropic 工程博客 "Effective Harnesses for Long-Running Agents"、"Harness Design for Long-Running Application Development" 及 OpenAI 工程博客 "Harness Engineering"，是本体系核心方法论的精华摘要。

## 核心问题：Agent 的失忆本质是工程问题

每个新会话都从零开始，没有上一次的记忆。这不是模型能力问题，而是工程设计问题。
解法是构建好的 **harness**——让 agent 在失忆的情况下依然有效工作。

## 三 Agent 模式

### Planner Agent（规划）
- 负责：维护 feature-list.json 的有效性
- 运行时机：项目初始化时（将需求拆解为 feature）；某个 feature 进入 blocked 状态时（尝试重规划）
- 自闭环：读取 feature-list.json 状态自行判断当前模式，无需调用方声明
- 产出：结构合理、每条 acceptance_criteria 可独立验证的 feature-list.json

### Coding Agent（Generator，开发）
- 负责：增量实现功能、更新进度、维护测试、做 git commit
- 每次会话：读取 git log → 读取 progress.json → 验证基础功能可用 → 实现功能 → 提交 Evaluator 验证
- blocked 时：调用 Planner 自动介入，不直接停止循环
- **不允许自评 passing**：功能完成后改为 `eval_pending`，由 Evaluator 独立验证
- **不允许修改 replanned 字段**：该字段只由 Planner 写入

### Evaluator Agent（QA，验证）
- 负责：独立验证 `eval_pending` 状态的功能
- 关键设计：不了解 Generator 的执行过程，只看代码库最终状态
- 立场：默认假设功能未完成，逐条验证 acceptance_criteria，任意一条失败则整体 fail
- 隔离性：通过 Claude Code 的 Agent tool 调用，提供天然的上下文隔离

## 为什么需要 Generator/Evaluator 分离

模型在评估自己的工作时存在系统性的乐观偏差。同一个 agent 既 generate 又 evaluate，等于让裁判兼任运动员。

分离后：Evaluator 被明确调校为「怀疑倾向」，不会被 Generator 的解释说服；Generator 有了具体可迭代的外部反馈；质量有了客观的验证锚点。

## 为什么需要 Planner

Coding Agent 只推进，Evaluator 只验证，但没有角色负责"计划本身是否还有效"。当某个 feature 反复失败，根因可能不是实现问题，而是 feature 粒度过大、依赖未声明、或需求本身有歧义。Planner 在 blocked 时介入诊断，尝试重规划，将人工介入节点从"所有 blocked"收窄到"Planner 也无法解决的 blocked"。

## 关键设计原则

### 1. progress.json 是必需品

长期任务必须维护结构化进度文件。它是唯一跨会话的「记忆」，也是 agent 之间交接的依据。
- 使用 JSON（比 Markdown 有更高的模型遵循率）
- 每完成一个功能立即更新，不攒到最后

### 2. Git 是状态机

每个有意义的进展对应一个 commit。git log 就是任务执行历史。
- 没有 commit = 没有证据 = 不可信
- 可以通过 git bisect 快速定位回退点

### 3. 测试是不可协商的约束

> "It is unacceptable to remove or edit tests because this could lead to missing or buggy functionality."

- 测试失败时，修复代码；不修改 assertion 让测试通过
- Playwright MCP 是 UI 项目端到端验证的有效工具

### 4. 功能列表用 JSON，不用 Markdown

JSON 格式比 Markdown checklist 有更高的模型遵循率。
每个功能包含：名称、status（failing/eval_pending/passing/blocked）、acceptance_criteria、replanned、eval_report。

**Feature 状态机**：

```
failing ←──────────────────── eval_pending ──→ passing
   ↑                                │
   │                     retry > 3  ↓
   │                             blocked
   │                                │
   │                     replanned = false?
   │                     ↙               ↘
   │             Planner 介入         replanned = true
   │             ↙         ↘           → 停止，通知用户
   │       拆分成功       无法拆分
   │     删原 feature    → replanned = true
   │     插子 feature    → 停止，通知用户
   │     (replanned=true)
   └──── 子 feature 进入正常循环
```

`replanned` 字段：只由 Planner 写入，从 `false` 变 `true` 后不可逆。子 feature 继承父 feature 的 `replanned: true`，确保 Planner 只有一次介入机会。

### 5. 一次只做一件事

每次会话聚焦于单个功能的完整实现和验证。完成 → eval_pending → Evaluator 通过 → commit → 再开始下一个。

### 6. Harness 组件代表对模型能力的假设

每个 harness 组件都编码了一个假设：「没有这个约束，模型会出错」。随着模型进化，某些假设会失效。
定期审查 `docs/harness-audit.md`，移除已被模型内化的约束。

## 闭环的三个阶段

```
开发（Generator）→ 验证（Evaluator）→ 沉淀（context/）
```

- **开发**：Coding Agent 按 feature-list.json 逐项实现，完成后改为 eval_pending
- **验证**：Evaluator 独立验证，pass 则改为 passing，fail 则退回 Generator 修复
- **沉淀**：将经验写入 context/ 文件，供后续项目 @import 复用

## 会话开始检查清单

```
□ 检测工作模式（feature-list.json + progress.json 是否存在）
□ git log --oneline -10（了解最近进展）
□ cat progress.json（了解当前状态和下一步）
□ 运行 test_command 验证基线可用
□ 选择第一个 failing 的功能开始实现
```

## 会话结束检查清单

```
□ 功能实现完成 → 改为 eval_pending → 调用 Evaluator
□ Evaluator 通过后 → status 变为 passing
□ 更新 progress.json（last_completed、completed_features、next_steps）
□ 运行完整测试套件，确保无回归
□ git commit（包含清晰的说明和 [progress: X/N]）
```

---

## 扩展原则（来自 OpenAI 工程实践）

### 7. AGENTS.md / CLAUDE.md 是目录，不是百科全书

保持在 100 行以内。内容是地图，不是手册：列出有哪些文档、各在哪、各管什么。
真正的知识存放在 `docs/` 和 `context/` 下的分层目录中。

### 8. Agent 可读性优先

Agent 在运行时无法访问的任何内容都是不存在的：
- Slack 记录、Google Docs、口头约定——对 Agent 都不存在
- 只有已提交到仓库的版本化工件才是 Agent 能推理的现实
- 每次架构决策必须落成 ADR，否则对 Agent 不存在

### 9. 熵管理：持续的「代码垃圾回收」

AI 会复现代码库中已存在的模式，包括不理想的模式。解法：
- 定义「黄金原则」：带主观意见的机械规则
- 将 code review 中的人工反馈转化为 context/ 更新，使其持续生效
- 技术债以小额方式持续偿还，优于积累后一次性解决
