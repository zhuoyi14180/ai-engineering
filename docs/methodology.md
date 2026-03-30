# AI 工程化闭环方法论

## 核心问题

AI 辅助编程引入了三个工程问题：
- **失忆问题**：每个新会话从零开始，没有上下文延续
- **质量漂移**：多次 AI 协作后代码风格和质量标准逐渐偏移
- **经验流失**：有价值的解法和决策没有沉淀，每次遇到相似问题都重新解决

本体系的目标：通过工程化手段解决这三个问题。

## 闭环结构

```
┌────────────────────────────────────────────────────────────┐
│                       闭环工作流                             │
│                                                             │
│  ┌──────────┐    ┌────────────┐    ┌─────────────────────┐  │
│  │   开发    │ →  │    验证    │ →  │        沉淀         │  │
│  │          │    │            │    │                     │  │
│  │ Coding   │    │  Evaluator │    │ context/ 专题知识   │  │
│  │  Agent   │    │  QA Agent  │    │ progress.json 进度  │  │
│  │          │    │  (隔离)    │    │ git history 记录    │  │
│  └──────────┘    └────────────┘    └─────────────────────┘  │
│       ↑                 │                    │               │
│       └─────────────────┘                    │               │
│            fail: 退回修复                     │               │
│       blocked: Planner 自动介入              ↓               │
│                                    供未来项目 @import 复用     │
└────────────────────────────────────────────────────────────┘
```

## 三 Agent 职责划分

| Agent | 职责 | 专属权限 |
|-------|------|---------|
| **Planner** | 维护 feature-list.json 的有效性；初始分解需求；blocked 时诊断根因并重规划 | 写 `acceptance_criteria`、`replanned` |
| **Coding Agent** | 增量实现功能；维护测试；做 git commit | 写 `status`（仅改为 `eval_pending`） |
| **Evaluator** | 独立验证 eval_pending 功能；逐条核查 acceptance_criteria | 写 `eval_report`、`status`（pass/fail/blocked） |

三者各自闭环，通过 feature-list.json 的字段分工协作，不直接共享执行上下文。

## 四个阶段详解

### 规划阶段（Planner）

**目标**：将需求拆解为结构清晰、可独立验证的 feature 集合

工具：
- `agents/planner.md`：Planner Agent 完整规范
- `templates/feature-list.json`：feature schema（含 `replanned`、`eval_report`）
- `templates/design-doc.md`：API 契约和数据模型设计文档
- `templates/adr.md`：架构决策记录

关键实践：
- 每个 feature 粒度以"一次可独立验证的交付"为标准，不大于一个 PR
- `acceptance_criteria` 必须是可直接写成测试用例的具体行为，不是模糊目标
- 识别依赖关系，优先拆出无依赖的基础 feature（数据模型、认证等）
- features >= 5 且涉及 API 或数据模型时，建议先起草 `docs/design.md`

### 开发阶段（Coding Agent）

**目标**：高效完成功能实现，保持工程质量一致

工具：
- `harnesses/claude-code/CLAUDE.md`：将个人偏好和规范编码为 AI 的永久上下文
- `agents/coding.md`：标准化 Coding Agent 的工作方式（三模式、eval_pending 约束）
- `skills/`：将常见操作（commit、review）封装为 slash command

关键实践：
- 每次会话开始读取 `progress.json` 和 git log
- 一次只实现一个功能，完成后改为 `eval_pending`，**不直接改为 passing**
- 调用 Evaluator（Agent tool）等待验证结果后再 commit
- feature 进入 blocked 时：先检查 `replanned` 字段，若为 `false` 则调用 Planner 自动介入，不直接停止循环

### 验证阶段（Evaluator）

**目标**：独立客观地验证功能质量，避免自评偏差

工具：
- `agents/evaluator.md`：Evaluator 的可执行规范，调校为怀疑倾向
- `context/evaluation-rubrics.md`：按项目类型的评估标准库
- Playwright MCP：UI 项目的端到端验证

关键实践：
- Evaluator 通过 Claude Code 的 Agent tool 调用，享有独立上下文（看不到 Generator 历史）
- 逐条验证 acceptance_criteria，任意一条失败 → 整体 fail
- retry_count > 3 → 改为 blocked，由 Planner 介入诊断根因

### 沉淀阶段

**目标**：将有价值的经验固化，供未来项目复用

工具：
- `context/`：专题知识片段，随项目积累不断丰富
- `agents/`：经过验证的 Agent prompt 模板
- `templates/`：经过实践检验的项目起始文件
- `docs/harness-audit.md`：harness 组件的假设登记和定期审查

**触发沉淀的场景：**
- 解决了卡住超过 30 分钟的问题
- `/review-pr` 发现某类问题在多个 PR 中反复出现
- 某个 context 文件超过 3 个月未更新，重读发现内容过时
- 功能实现比 acceptance_criteria 描述的更复杂，且复杂度是可预见的

执行：`/update-context <问题描述>` 将发现提炼为 context 文件的具体条目。

## 配置分层模型

```
Layer 1: ~/.claude/CLAUDE.md        个人全局偏好（本仓库维护，make install-claude 部署）
    ↓ 始终加载
Layer 2: <project>/CLAUDE.md        项目上下文（@import context/ 引用）
    ↓ 项目加载
Layer 3: context/*.md               专题知识片段（按需引用）
    ↓ 按需加载
Layer 4: progress.json              当前任务状态（会话桥梁）
```

每一层的关注点：
- **Layer 1**：我是谁（偏好、约束、工作方式）
- **Layer 2**：这个项目是什么（目标、技术栈、特定规范）
- **Layer 3**：相关领域知识（编码规范、安全、测试等）
- **Layer 4**：现在在哪（当前任务进度、下一步）

## 与 Anthropic 文章的对应关系

| 文章建议 | 本体系实现 |
|---------|-----------|
| Generator/Evaluator 分离 | `agents/coding.md` + `agents/evaluator.md`，通过 Agent tool 实现上下文隔离 |
| 主观标准操作化 | `context/evaluation-rubrics.md` 按项目类型定义检查项 |
| Sprint Contract | `acceptance_criteria` + `eval_report` 在 feature-list.json 中编码 |
| 三 Agent 模式 | Planner（规划）+ Coding Agent（开发）+ Evaluator（验证） |
| JSON 功能列表 | `templates/feature-list.json`，含 `replanned`、`eval_report` 字段 |
| progress 文件 | `templates/progress.json` + CLAUDE.md 约束 |
| Git 作为状态机 | context/git-workflow.md + CLAUDE.md Git 规范 |
| 测试不可跳过 | CLAUDE.md 硬性测试约束 |
| Harness 假设审计 | `docs/harness-audit.md` + 定期 review 流程 |
