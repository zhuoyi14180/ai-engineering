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
