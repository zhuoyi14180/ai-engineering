# 新项目接入指南

本文档说明如何将 `ai-engineering` 体系接入一个新项目。

## 前提

在开始接入新项目之前，需先在本机完成一次性的全局安装。根据使用的 AI 工具选择对应的 harness：

```bash
cd /path/to/ai-engineering

# Claude Code（安装到 ~/.claude/）
make install-claude

# Codex CLI（安装到 ~/.codex/ + ~/.agents/skills/）
make install-codex

# Cursor（安装到指定项目目录）
make install-cursor PROJECT_DIR=/path/to/project
```

`install-claude` 会将 `harnesses/claude-code/` 下的配置（CLAUDE.md、settings.json、hooks、skills）同步到 `~/.claude/`，对该机器上所有 Claude Code 项目生效。

## 方式一：Git Submodule（推荐）

适用于需要版本锁定的项目。

```bash
# 在项目根目录执行
git submodule add https://github.com/<user>/ai-engineering .ai-engineering

# 首次安装全局配置（仅需执行一次，在同一台机器上）
cd .ai-engineering && make install-claude && cd ..

# 锁定到特定版本（推荐）
cd .ai-engineering && git checkout v1.0.0 && cd ..
git add .ai-engineering && git commit -m "chore: pin ai-engineering to v1.0.0"
```

**更新 submodule**：
```bash
cd .ai-engineering && git pull origin main
make diff
make install-claude
```

## 方式二：直接引用（轻量）

适用于个人项目，不想引入 submodule 依赖。

直接在项目的 `CLAUDE.md` 中引用（此处需替换为真实路径）：

```markdown
@/path/to/ai-engineering/context/coding-standards.md
@/path/to/ai-engineering/context/testing-patterns.md
```

## 创建项目 CLAUDE.md

复制模板并按需修改：

```bash
cp .ai-engineering/templates/project-CLAUDE.md CLAUDE.md
```

模板包含：
- 项目概述填写区域
- 常用 context 文件的 `@import` 语句（按需保留）
- 项目特定规范区域

## 启动长期开发任务

### 分支 A：使用 /init-project skill（推荐）

在 Claude Code 对话中运行：

```
/init-project <项目描述>
```

skill 会自动生成 `feature-list.json` 和 `progress.json`，完成环境搭建和初始 commit。

### 分支 B：手动初始化

不使用 skill 时，手动复制模板并填写：

```bash
cp .ai-engineering/templates/feature-list.json feature-list.json
cp .ai-engineering/templates/progress.json progress.json
```

然后填写两个文件中的占位符字段：
- `feature-list.json`：替换 `<project_name>`、`<ISO 8601 datetime>`，将示例功能条目改为真实功能
- `progress.json`：填写 `project`、`last_updated`、`total_features`（与功能数一致）、`environment` 下的四个命令（`setup_command`、`test_command`、`build_command`、`dev_command`）

#### 如何写好 acceptance_criteria

`acceptance_criteria` 是 Coding Agent 的实现依据，也是 TDD 的测试设计来源。每条标准必须是**可验证的具体行为**，而不是模糊的目标描述。

**判断标准**：能直接写成一个测试用例的，才是好的验收标准。

| 反例（不可测试） | 正例（可直接写成测试） |
|----------------|----------------------|
| `"用户可以登录"` | `"POST /api/auth/login with valid credentials returns 200 and a JWT token"` |
| `"错误处理正确"` | `"POST /api/users with missing email field returns 400 with error message 'email is required'"` |
| `"性能良好"` | `"GET /api/products returns response within 200ms for up to 1000 items"` |
| `"数据持久化"` | `"Created user persists after server restart and can be retrieved by ID"` |

**写法原则**：
- 包含触发条件（做什么操作）
- 包含期望结果（系统如何响应）
- 不描述实现方式（只说输入和输出）
- 一条标准验证一个行为，不合并多个

### 后续开发（两种分支通用）

启动 Coding Agent（参考 `.ai-engineering/agents/coding/prompt.md`），每次新会话粘贴该 prompt 作为开场，Agent 会自动读取 `progress.json` 接续上次进度。

## 文件结构建议

```
<project>/
├── CLAUDE.md                  # 项目级配置（引用 ai-engineering context）
├── .ai-engineering/           # submodule
├── feature-list.json          # 功能列表（长期任务时创建）
├── progress.json              # 进度追踪（长期任务时创建）
└── .claude/
    ├── settings.json          # 项目级 hooks（可选）
    └── rules/                 # 路径匹配规则（可选）
        ├── api-rules.md
        └── test-rules.md
```

## 同步全局配置

当 `ai-engineering` 有更新时：
```bash
cd .ai-engineering
git pull origin main
make diff         # 预览 claude-code harness 与 ~/.claude/ 的差异
make install-claude  # 同步到 ~/.claude/
```
