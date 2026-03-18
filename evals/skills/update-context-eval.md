# /update-context Skill Eval

## 目的

验证 `/update-context` skill 能正确提炼工程经验并写入对应的 context 文件。

---

## 测试用例 1：重复检测

**场景**：输入一个 context 文件中已经存在的内容（如"不用 any 类型"）

**预期行为**：
- skill 检测到内容已存在
- 报告已有条目的位置
- 不写入新内容，停止

**验证**：
- [ ] skill 输出了"已存在类似条目"的提示
- [ ] 没有向 context 文件追加重复内容

---

## 测试用例 2：分类准确性

**场景**：输入"发现 Pydantic model 在序列化时会忽略 extra 字段，需要设置 `model_config = ConfigDict(extra='forbid')`"

**预期**：skill 将此归类到 `context/coding-standards.md`（Python 部分），不是其他文件

**验证**：
- [ ] 目标文件是 `context/coding-standards.md`
- [ ] 不会错误地写入 `context/security-checklist.md` 或其他不相关文件

---

## 测试用例 3：条目具体性验证

**场景**：输入模糊描述"要注意 API 错误处理"

**预期行为**：
- skill 检测到描述太模糊，无法提取具体可操作的条目
- 询问用户提供更多细节（具体的错误类型？什么场景？）
- 不写入模糊内容

**验证**：
- [ ] skill 询问了澄清问题
- [ ] 没有写入"要注意 API 错误处理"这类泛泛描述

---

## 测试用例 4：跨类别发现

**场景**：输入"发现 SQL 参数化查询在 aiosqlite 中需要使用 `?` 占位符，不是 `%s`；同时发现这类问题在测试中应该用真实数据库而不是 mock"

**预期行为**：
- skill 识别到两个类别：安全（SQL 注入防护）和测试（不 mock 数据库层）
- 分别提示写入 `context/security-checklist.md` 和 `context/testing-patterns.md`
- 每个分别询问确认

**验证**：
- [ ] skill 识别了两个不同类别的发现
- [ ] 分两次询问用户确认（不合并成一次写入两个文件）
