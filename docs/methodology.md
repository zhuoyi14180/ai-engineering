# AI 工程化闭环方法论

## 核心问题

AI 辅助编程带来了效率提升，但也引入了新的挑战：
- **失忆问题**：每个新会话从零开始，没有上下文延续
- **质量漂移**：多次 AI 协作后代码风格和质量标准逐渐偏移
- **经验流失**：有价值的解法和决策没有沉淀，每次遇到相似问题都重新解决

本体系的目标：通过工程化手段解决这三个问题。

## 闭环结构

```
┌─────────────────────────────────────────────────────┐
│                    闭环工作流                         │
│                                                      │
│  ┌────────┐    ┌────────┐    ┌────────────────────┐  │
│  │  开发  │ →  │  纠错  │ →  │       沉淀         │  │
│  │        │    │        │    │                    │  │
│  │Coding  │    │Testing │    │context/ 专题知识   │  │
│  │Agent   │    │Evals   │    │progress.json 进度  │  │
│  │Skills  │    │Hooks   │    │git history 记录    │  │
│  └────────┘    └────────┘    └────────────────────┘  │
│       ↑                              │               │
│       └──────────────────────────────┘               │
└─────────────────────────────────────────────────────┘
```

## 三个阶段详解

### 开发阶段

**目标**：高效完成功能实现，保持一致的工程质量

工具：
- `global/CLAUDE.md`：将个人偏好和规范编码为 AI 的永久上下文
- `agents/coding/prompt.md`：标准化 Coding Agent 的工作方式
- `global/skills/`：将常见操作（commit、review）封装为 slash command

关键实践：
- 每次会话开始前读取 `progress.json` 和 git log
- 一次只实现一个功能，完成即 commit
- Git commit 作为进度里程碑

### 纠错阶段

**目标**：及时发现和修正偏差，防止问题积累

工具：
- `global/hooks/`：自动化的质量守门员（格式化、危险操作拦截）
- `evals/`：量化评估 skill 和 prompt 的质量
- `context/testing-patterns.md`：测试规范的持续传递

关键实践：
- 测试是不可协商的约束（CLAUDE.md 中硬编码）
- hooks 自动 format，减少人工干预
- evals 在每次修改 CLAUDE.md 或 skills 后运行

### 沉淀阶段

**目标**：将有价值的经验固化，供未来项目复用

工具：
- `context/`：专题知识片段，随项目积累不断丰富
- `agents/`：经过验证的 Agent prompt 模板
- `templates/`：经过实践检验的项目起始文件

关键实践：
- 遇到好的解法，写入对应的 context 文件
- 遇到常见的错误，加入 pre-bash-check.sh 的拦截规则
- 定期 review `global/CLAUDE.md`，确保规范仍然适用

## 配置分层模型

```
Layer 1: ~/.claude/CLAUDE.md       个人全局偏好（本仓库维护）
    ↓ 始终加载
Layer 2: <project>/CLAUDE.md       项目上下文（@import Layer 3）
    ↓ 项目加载
Layer 3: context/*.md              专题知识片段（按需引用）
    ↓ 按需加载
Layer 4: progress.json             当前任务状态（会话桥梁）
```

每一层的关注点：
- Layer 1：**我是谁**（偏好、约束、工作方式）
- Layer 2：**这个项目是什么**（目标、技术栈、特定规范）
- Layer 3：**相关领域知识**（编码规范、安全、测试等）
- Layer 4：**现在在哪**（当前任务进度、下一步）

## 与 Anthropic 文章的对应关系

| 文章建议 | 本体系实现 |
|---------|-----------|
| 双 Agent 模式 | `agents/initializer/` + `agents/coding/` |
| JSON 功能列表 | `templates/feature-list.json` |
| progress 文件 | `templates/progress.json` + CLAUDE.md 约束 |
| Git 作为状态机 | git-workflow context + CLAUDE.md Git 规范 |
| 测试不可跳过 | CLAUDE.md 硬性测试约束 |
| 浏览器自动化 | `mcps/README.md` Puppeteer MCP |
| 会话开始验证 | `agents/coding/prompt.md` 检查清单 |
