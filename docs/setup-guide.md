# 新项目接入指南

本文档说明如何将 `ai-engineering` 体系接入一个新项目。

## 方式一：Git Submodule（推荐）

适用于需要版本锁定的项目。

```bash
# 在项目根目录执行
git submodule add https://github.com/<user>/ai-engineering .ai-engineering

# 首次安装全局配置（仅需执行一次，在同一台机器上）
cd .ai-engineering && make install && cd ..

# 锁定到特定版本（推荐）
cd .ai-engineering && git checkout v1.0.0 && cd ..
git add .ai-engineering && git commit -m "chore: pin ai-engineering to v1.0.0"
```

**更新 submodule**：
```bash
cd .ai-engineering && git pull origin main && cd ..
make diff   # 预览变更
make update # 应用变更到 ~/.claude/
```

## 方式二：直接引用（轻量）

适用于个人项目，不想引入 submodule 依赖。

直接在项目的 `CLAUDE.md` 中使用绝对路径引用：

```markdown
@/Users/jorizhang/projects/mine/ai-engineering/context/coding-standards.md
@/Users/jorizhang/projects/mine/ai-engineering/context/testing-patterns.md
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

1. 使用 `/init-project` skill（如已安装）或手动执行 Initializer Agent：
   ```
   参考 .ai-engineering/agents/initializer/prompt.md
   ```

2. 复制模板文件到项目根目录：
   ```bash
   cp .ai-engineering/templates/feature-list.json feature-list.json
   cp .ai-engineering/templates/progress.json progress.json
   ```

3. 填写 `feature-list.json` 中的功能列表

4. 启动 Coding Agent（参考 `.ai-engineering/agents/coding/prompt.md`）

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
make diff    # 预览差异
make update  # 同步到 ~/.claude/
```
