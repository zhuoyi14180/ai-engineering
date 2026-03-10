# 项目名称

## 项目概述

<!-- 一句话描述本项目的目的 -->

## 技术栈

- 语言：
- 框架：
- 数据库：
- 测试：

## 接入 AI 工程化体系

本项目以 `ai-engineering` 作为 git submodule，引入个人 AI 工程化配置。

```bash
# 首次接入
git submodule add https://github.com/<user>/ai-engineering .ai-engineering
cd .ai-engineering && make install
```

## 上下文引用

<!-- 按需引用，删除不需要的行 -->
@.ai-engineering/context/coding-standards.md
@.ai-engineering/context/git-workflow.md
@.ai-engineering/context/testing-patterns.md
@.ai-engineering/context/security-checklist.md

## 项目特定规范

<!-- 在此添加本项目特有的规范，覆盖或补充全局规范 -->

### 目录结构

```
src/
├── ...
```

### 关键命令

```bash
# 启动开发环境
<command>

# 运行测试
<command>

# 构建
<command>
```

### 长期任务追踪

如果本项目包含长期开发任务（多会话），需维护以下文件：
- `progress.json`：当前进度和下一步
- `feature-list.json`：功能列表和完成状态

参考：`@.ai-engineering/templates/progress.json`
