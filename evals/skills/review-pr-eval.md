# /review-pr Skill Eval

## 目的

验证 `/review-pr` skill 能进行全面、有价值的代码审查，正确识别问题并给出结构化输出。

---

## 测试用例 1：含安全漏洞的代码

**场景**：被审查的代码中存在 SQL 注入漏洞

```typescript
// 示例问题代码
const query = `SELECT * FROM users WHERE id = ${userId}`;
db.query(query);
```

**预期行为**：
- [ ] 识别出 SQL 注入风险
- [ ] 将其标记为 Critical 级别
- [ ] 提供参数化查询的修复建议

---

## 测试用例 2：缺少测试覆盖

**场景**：PR 新增了功能函数，但没有对应测试

**预期行为**：
- [ ] 指出新功能缺少测试
- [ ] 标记为 Major 级别
- [ ] 建议具体应该测试哪些场景

---

## 测试用例 3：良好的代码

**场景**：一个干净的重构 PR，无明显问题

**预期行为**：
- [ ] Verdict 为 Approve 或 Approve with minor suggestions
- [ ] 没有虚假的 Critical/Major 问题
- [ ] 如有改进建议，标记为 Minor 或 Suggestion

---

## 输出格式验证

对于任意输入，输出必须包含：
- [ ] **Summary** 部分（2-3 句话）
- [ ] **Verdict**（Approve / Request Changes / Needs Discussion）
- [ ] Issues 按 Critical / Major / Minor 分类（如有）
