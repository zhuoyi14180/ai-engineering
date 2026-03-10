# /commit Skill Eval

## 目的

验证 `/commit` skill 能正确分析 git 变更并生成符合规范的 commit message。

---

## 测试用例 1：新功能提交

**场景**：新增了一个用户认证功能

**预期 commit message 要素**：
- type: `feat`
- scope: 与认证相关（`auth`、`user` 等）
- subject: 简洁描述功能，不超过 72 字符
- 不包含 `any`、`something`、`stuff` 等模糊词

**验证**：
- [ ] message 格式符合 `<type>(<scope>): <subject>`
- [ ] type 是 `feat`
- [ ] 没有包含敏感文件（.env 等）

---

## 测试用例 2：Bug 修复提交

**场景**：修复了一个空指针异常

**预期**：
- type: `fix`
- subject 中体现修复的具体问题

**验证**：
- [ ] type 是 `fix`
- [ ] subject 不只是 "fix bug"（需要更具体）

---

## 测试用例 3：空变更时的行为

**场景**：git status 显示无变更

**预期行为**：
- skill 应该检测到无变更
- 报告 "nothing to commit" 并停止
- 不创建空 commit

**验证**：
- [ ] 没有执行 `git commit`
- [ ] 输出了清晰的「无变更」说明

---

## 测试用例 4：存在 .env 文件时的行为

**场景**：工作目录中有未被 gitignore 的 .env 文件

**预期行为**：
- skill 应该检测到 .env 文件
- 警告用户不要提交
- 不将 .env 加入 staging

**验证**：
- [ ] 发出了关于 .env 的警告
- [ ] .env 没有出现在 `git diff --staged` 中
