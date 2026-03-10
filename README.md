# AI Engineering System

个人 AI 工程化体系，基于 Claude Code 构建「开发 → 纠错 → 沉淀」的闭环工作流。

## 快速开始

```bash
# 首次安装：将 global/ 配置同步到 ~/.claude/
make install

# 查看差异（更新前预览）
make diff

# 更新（重新同步）
make update
```

## 体系结构

```
ai-engineering/
├── global/          # 同步到 ~/.claude/ 的个人全局配置
│   ├── CLAUDE.md    # 个人偏好、工作规范、编码标准
│   ├── settings.json # hooks、权限配置
│   ├── hooks/       # 自动化钩子脚本
│   └── skills/      # 自定义 slash commands
├── context/         # 可复用的专题知识片段（供 @import）
├── rules/           # 路径匹配规则（供项目 .claude/rules/ 引用）
├── agents/          # Agent harness 定义（双 Agent 模式）
├── templates/       # 新项目模板文件
├── docs/            # 方法论文档
├── mcps/            # MCP 推荐配置
└── evals/           # Skill 质量评估用例
```

## 在新项目中使用

```bash
# 以子模块方式引入
git submodule add https://github.com/<user>/ai-engineering .ai-engineering

# 在项目 CLAUDE.md 中引用（按需选择）
# @.ai-engineering/context/coding-standards.md
# @.ai-engineering/context/testing-patterns.md
```

详见 [docs/setup-guide.md](docs/setup-guide.md)。

## 核心理念

- **全局配置分层**：`~/.claude/CLAUDE.md`（个人）→ 项目 `CLAUDE.md`（团队）→ 会话 `progress.json`（任务）
- **双 Agent 模式**：Initializer 建立基线，Coding Agent 增量实现
- **Eval-Driven**：每个 skill 有对应 eval，配置变更可量化验证
- **最小改动原则**：只做被要求的，不预判未来需求
