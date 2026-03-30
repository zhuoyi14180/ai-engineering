# Personal Preferences & Coding Standards

> Auto-generated from harnesses/claude-code/CLAUDE.md
> Do not edit directly — run `make build` to regenerate.

# 个人信息与沟通偏好

- 语言：中文交流，代码、变量名、注释用英文
- 风格：简洁精准，不加 emoji，避免冗余解释
- 对话格式：直接给出结论，必要时附原因；不用问候语开头

# 工作流规范

## 工作模式检测

每次会话开始时，通过以下文件存在性自动推断工作模式：

| 条件 | 模式 |
|------|------|
| `progress.json` + `feature-list.json` 同时存在 | **auto-coding**（自动化）|
| 只有 `feature-list.json` 存在 | **spec-coding**（结构化交互）|
| 两者都不存在 | **vibe-coding**（自由探索）|

不同模式下的行为约束不同，详见后续各章节说明。

## 任务启动

- 非平凡任务（超过 3 步或改动超过 2 个文件）先进入 Plan 模式
- **auto-coding 模式**：每个会话开始前必须执行状态检查（pwd → git log → progress.json → feature-list.json → test_command）
- **spec-coding 模式**：会话开始时确认工作目录和 git log；如有 feature-list.json 则读取
- **vibe-coding 模式**：仅确认工作目录，直接询问用户要做什么
- **auto-coding 模式**：必须在项目根目录维护 `progress.json`；spec-coding / vibe-coding 模式不强制

## 代码修改原则

- 先读再改：绝不对未读的文件提修改建议
- 最小改动：不添加未被明确要求的功能、注释、错误处理
- 优先复用：找到现有实现再考虑新写
- 不过度工程化：三行重复代码优于过早抽象

## 测试约束（硬性规则）

- 不允许删除或注释掉测试用例
- 不允许为通过测试而修改 assertion（除非需求变更）
- 新功能必须附带测试

## Git 规范

- 非平凡的 push、force push、reset --hard 等操作执行前须确认
- commit 格式和分支策略详见 @context/git-workflow.md
- 做出以下决策时记录 ADR（`docs/adr-<NNN>-<topic>.md`，如 `adr-001-auth-method.md`）：框架选型、认证方案、存储选型、外部服务引入

# 编码偏好

## 常用语言

TypeScript、Python、Go、Java，具体选择视项目技术栈而定。

## TypeScript / JavaScript

- 使用 ES modules（import/export），不用 CommonJS（require）
- 函数式优于命令式（在合理范围内）
- 类型定义明确，避免 `any`

## Python

- 优先 Python 3.10+，使用类型注解
- 工具链：uv（包管理）、ruff（lint/format）、pytest（测试）

## Go

- 遵循 `gofmt` 格式化
- error 处理：显式检查，`errors.Is`/`errors.As` 做类型判断
- 接口定义在消费者侧（最小接口原则）

## Java

- 目标 Java 17+（LTS 版本）
- 构建工具：Maven 或 Gradle，视项目而定
- 格式化：google-java-format 或 Spotless
- 测试：JUnit 5 + Mockito

## 通用

- 错误处理：只在系统边界（用户输入、外部 API）做防御；内部逻辑信任约束
- 不写仅注释掉、添加 `_unused` 前缀或重导出的向后兼容 hack

# 安全约束

- 不生成可能包含命令注入、SQL 注入、XSS 的代码，发现后立即修复
- 不将密钥、token、密码写入代码或 git 追踪的文件

# 安全清单

## 输入验证（所有外部输入必须验证）

- [ ] 用户输入在系统边界处验证，不信任任何外部数据
- [ ] 文件路径输入：防止路径遍历（`../`）
- [ ] 整数/数字：检查范围，防止整数溢出
- [ ] 字符串长度：设置最大长度限制

## 注入类漏洞

- [ ] SQL：使用参数化查询或 ORM，不拼接 SQL 字符串
- [ ] 命令注入：不将用户输入传入 shell 命令；必须时用参数列表而非字符串
- [ ] XSS：HTML 输出时转义特殊字符；CSP 头部配置
- [ ] 路径注入：使用 `path.join` + 规范化后验证前缀

## 认证与授权

- [ ] 密码存储：bcrypt / argon2，不存明文或 MD5/SHA1
- [ ] JWT：验证签名、过期时间；使用强密钥
- [ ] Session：HttpOnly + Secure cookie；合理过期时间
- [ ] 权限检查：每个 API 端点独立验证，不依赖前端隐藏

## 敏感数据

- [ ] 密钥/Token 不写入代码
- [ ] 密钥/Token 不提交到 git（检查 .gitignore）
- [ ] 日志中不打印密码、token、PII
- [ ] 环境变量通过 `.env` 文件管理，`.env` 在 .gitignore 中

## 依赖安全

- [ ] 定期运行 `npm audit` / `pip-audit` / `govulncheck`
- [ ] 锁定依赖版本（package-lock.json / uv.lock）
- [ ] 不使用有已知高危漏洞的依赖版本

## API 安全

- [ ] HTTPS only（不允许 HTTP 降级）
- [ ] Rate limiting（防止暴力破解）
- [ ] CORS：明确配置允许的 Origin，不使用 `*`
- [ ] 错误响应：不暴露内部实现细节（堆栈跟踪等）

## 文件操作

- [ ] 上传文件：验证文件类型（Magic bytes，不只是扩展名）
- [ ] 上传文件：限制大小
- [ ] 存储路径不在 web 可访问目录


# AI 工程化上下文

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


# 常用资源引用

# 编码规范

## TypeScript / JavaScript

### 模块系统
- 使用 ES modules（`import`/`export`），不使用 CommonJS（`require`/`module.exports`）
- 具名导出优先于默认导出（便于重构和 IDE 支持）
- 解构导入：`import { foo, bar } from './module'`

### 类型系统
- 避免 `any`；必要时用 `unknown` 替代
- 接口优于类型别名（`interface` vs `type`）描述对象结构
- 函数参数和返回值必须有明确类型，不依赖推导

### 代码风格
- 函数式优于命令式（合理范围内）
- 纯函数优于有副作用的函数
- 短路求值和可选链：`obj?.foo ?? defaultVal`
- 避免嵌套超过 3 层；提前 return 代替 if-else 嵌套

### 工具链
- 包管理：pnpm 优先，其次 npm
- 格式化：Prettier（默认配置）
- Lint：ESLint + typescript-eslint
- 测试：Vitest（Node）或 Jest

---

## Python

### 版本与环境
- 目标 Python 3.10+
- 包管理：uv（`uv add`、`uv run`）
- 虚拟环境：由 uv 自动管理（`.venv/`）

### 代码风格
- 使用类型注解（PEP 484）
- dataclass 或 Pydantic model 代替裸 dict 传参
- 上下文管理器处理资源（`with` 语句）
- f-string 格式化，不用 `%` 或 `.format()`

### 工具链
- 格式化 + Lint：ruff（`ruff format`、`ruff check`）
- 类型检查：mypy 或 pyright
- 测试：pytest + pytest-cov

---

## Go

### 代码风格
- 遵循 `gofmt` 格式化（提交前必须运行）
- error 处理：显式检查，不忽略；`errors.Is`/`errors.As` 做判断
- 接口定义在消费者侧（最小接口原则）
- 避免 init()；避免全局可变状态

### 工具链
- 格式化：gofmt / goimports
- Lint：golangci-lint
- 测试：go test（table-driven tests）

---

## Java

### 版本与环境
- 目标 Java 17+（LTS）；新项目优先 Java 21
- 构建工具：Maven 或 Gradle，视项目技术栈和团队约定而定

### 代码风格
- 遵循 Google Java Style Guide
- 格式化：google-java-format 或 Spotless 插件（集成在构建工具中）
- 泛型类型参数必须明确，不用原始类型（`List` → `List<String>`）
- 优先不可变对象：`final` 字段，record 类型（Java 16+）
- 用 `Optional` 表达可空返回值，不返回 `null`

### 工具链
- 格式化：google-java-format
- Lint / 静态分析：Checkstyle + SpotBugs
- 测试：JUnit 5 + Mockito + AssertJ
- 覆盖率：JaCoCo

---

## 通用原则

- **可读性优先**：代码是写给人读的，机器执行是其次
- **命名清晰**：变量名表达意图，不用缩写（除非约定俗成如 `ctx`、`err`、`i`）
- **函数单一职责**：一个函数做一件事，不超过 30 行为参考上限
- **注释说「为什么」，不说「是什么」**：代码本身说明是什么，注释解释为何这样做
- **不写防御性代码处理不可能发生的情况**：只在系统边界（用户输入、外部 API 响应）做验证

# Git 工作流

## Commit 规范

### Message 格式
```
<type>(<scope>): <subject>

[可选 body：说明原因和背景]

[可选 footer：关联 issue、breaking change 等]
```

### Type 枚举
| type | 用途 |
|------|------|
| `feat` | 新功能 |
| `fix` | Bug 修复 |
| `refactor` | 重构（不改变行为） |
| `test` | 测试相关 |
| `docs` | 文档 |
| `chore` | 构建、工具链、依赖更新 |
| `perf` | 性能优化 |

### 规则
- subject 用祈使语气，中文可接受（`feat(auth): 添加 JWT 刷新逻辑`）
- subject 不超过 72 字符
- body 解释「为什么」，不重复「是什么」
- 每个 commit 代表一个逻辑完整的最小变更

## 分支策略

- `main` / `master`：始终保持可部署状态
- 功能分支：`feat/<name>`，从 main 切出，完成后 PR 合并
- 修复分支：`fix/<name>`
- 长期任务分支：分支上维护 `progress.json`，多次 commit

## 危险操作规范

以下操作执行前**必须向用户确认**：

- `git push --force`（即使是自己的分支）
- `git reset --hard`（有未保存工作时）
- `git rebase`（已 push 的提交）
- 删除远端分支（`git push origin --delete`）

## PR / Code Review 规范

- PR 标题遵循 commit 格式
- PR description 包含：变更摘要、测试方式、截图（UI 变更时）
- 自 review 后再请求他人：至少自己看一遍 diff
- 合并前 CI 必须全绿

## 长期任务的 Git 使用

对应 Anthropic 文章的「Git 作为状态机」理念：

- 完成每个功能点立即 commit（不攒到最后）
- commit message 中包含 `[progress]` 标记，便于追踪
- 例：`feat(auth): 实现登录接口 [progress: 3/10 features]`

## 架构决策记录（ADR）

做出以下决策时创建 ADR：框架选型、认证方案、存储选型、外部服务引入。

文件命名：`docs/adr-<NNN>-<topic>.md`
- NNN：三位数字，从 001 开始，按创建顺序递增
- topic：kebab-case 短标题，描述决策主题
- 示例：`docs/adr-001-auth-method.md`、`docs/adr-002-database-choice.md`

使用 `templates/adr.md` 创建。

# 测试策略

## 核心原则

**测试是不可协商的约束**（来自 Anthropic 工程实践）：
- 不删除或注释掉已有测试
- 不修改 assertion 来让测试通过（除非需求确实变更）
- 不因为「时间紧」跳过测试
- 新功能必须附带测试，否则视为未完成

## 测试分层

```
E2E Tests（端到端）
    ↑
Integration Tests（集成）
    ↑
Unit Tests（单元）← 大多数测试在这里
```

- 单元测试：纯函数、业务逻辑、工具函数
- 集成测试：模块间交互、数据库操作、外部服务 mock
- E2E 测试：关键用户路径，用浏览器自动化（Playwright）

## 各语言测试工具

| 语言 | 测试框架 | Mock | 覆盖率 |
|------|---------|------|--------|
| TypeScript | Vitest / Jest | vi.mock / jest.mock | vitest --coverage |
| Python | pytest | pytest-mock / unittest.mock | pytest-cov |
| Go | go test | testify/mock | go test -cover |
| Java | JUnit 5 | Mockito | JaCoCo |

## 测试命名规范

```typescript
// TypeScript - describe/it 结构
describe('UserService', () => {
  describe('createUser', () => {
    it('should return created user when valid input', () => {})
    it('should throw ValidationError when email is invalid', () => {})
  })
})
```

```python
# Python - 函数命名
def test_create_user_returns_user_when_valid_input(): ...
def test_create_user_raises_validation_error_when_email_invalid(): ...
```

```java
// Java - JUnit 5 嵌套类风格
@DisplayName("UserService")
class UserServiceTest {
    @Nested
    @DisplayName("createUser")
    class CreateUser {
        @Test
        void shouldReturnCreatedUserWhenValidInput() {}

        @Test
        void shouldThrowValidationExceptionWhenEmailIsInvalid() {}
    }
}
```

## 测试数据管理

- 使用 factory 函数或 fixtures 生成测试数据，不硬编码
- 测试之间相互独立，不依赖执行顺序
- 数据库测试：每个测试前清理，使用事务回滚

## 浏览器自动化（E2E）

对于 Web 应用，使用 Playwright 做端到端验证：
- 关键用户流程必须有 E2E 覆盖（登录、核心业务动作）
- E2E 跑在 CI 中，失败时阻断合并
- 参考 `mcps/README.md` 中的 Playwright MCP 配置

## CI 集成

- 每次 commit 触发单元测试
- PR 合并前触发完整测试套件（含集成测试）
- 覆盖率下降时给出警告（不强制阻断，但需关注）

## Eval 可靠性（Agentic 场景）

来源：Anthropic《Quantifying infrastructure noise in agentic coding evals》（2026-03）

Agent 的 eval 结果本身是有噪声的。基础设施因素（网络延迟、超时、资源竞争、并发冲突）会导致相同 prompt 在相同代码下产生不同的 pass/fail 结果，这种噪声有时足以淹没模型能力的真实差异。

**实践规则：**

- 关键行为（尤其是 Agent 决策路径、工具调用链）至少跑 3 次，取多数结果，不信任单次结论
- 区分两类失败：
  - `flaky`：偶发、不可复现 → 基础设施噪声，不视为 regression
  - `regression`：稳定复现 → 真实问题，必须修复后才能合并
- 新增 eval 在纳入 CI 前，先做「基线噪声测量」：在干净状态下跑 5 次，记录通过率，低于 90% 的 eval 不应作为合并 gate
- 高价值但高噪声的 eval 可以移出 PR gate，改为定期跑（每日/每周），单独追踪趋势

**eval 质量分级参考：**

| 通过率（干净状态） | 适合做 | 不适合做 |
|--------------------|--------|---------|
| ≥ 95% | PR gate | — |
| 80–95% | 定期监控 | PR gate |
| < 80% | 问题排查信号 | 任何自动决策 |
