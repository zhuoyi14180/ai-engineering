# /init-project Skill Eval

## 目的

验证 `/init-project` skill 能正确初始化项目，生成高质量的 feature-list.json 和 progress.json。

---

## 测试用例 1：acceptance_criteria 质量验证

**场景**：用户描述"构建一个 REST API，支持用户注册和登录"

**预期**：acceptance_criteria 中每条标准都是可测试的具体行为

**验证**：
- [ ] 每条标准包含触发条件（如 `POST /api/auth/register with ...`）
- [ ] 每条标准包含期望结果（如 `returns 201 and ...`）
- [ ] 没有模糊描述（如"用户可以注册"、"登录功能正常"）
- [ ] 每条标准只验证一个行为，不合并多个

**反例**（应触发修正）：
```json
"acceptance_criteria": ["用户注册功能可以正常工作"]
```

**正例**：
```json
"acceptance_criteria": [
  "POST /api/auth/register with valid name, email, password returns 201 and user object (without password)",
  "POST /api/auth/register with duplicate email returns 409 with error message"
]
```

---

## 测试用例 2：feature 依赖关系完整性

**场景**：项目包含"用户注册"和"用户登录"两个功能

**预期**：如果"登录"依赖"注册"的用户数据，`depends_on` 字段应标明

**验证**：
- [ ] 有明显依赖关系的功能，`depends_on` 字段不为空
- [ ] 依赖项的 ID 引用的是实际存在的功能

---

## 测试用例 3：复杂项目触发 design-doc 建议

**场景**：用户描述一个有 6 个以上功能且涉及 API 设计的项目

**预期行为**：
- skill 应建议先创建 `docs/design.md`
- 不强制阻断，用户说"跳过"时继续

**验证**：
- [ ] 输出了关于 design-doc 的建议
- [ ] 建议中提到了 `templates/design-doc.md`
- [ ] 用户拒绝后，skill 继续正常执行

---

## 测试用例 4：test_command 验证

**场景**：Node.js 项目

**预期**：progress.json 中的 test_command 是实际可运行的命令

**验证**：
- [ ] test_command 不是占位符（如 `<command>`）
- [ ] 在项目目录中运行 test_command 不报"命令未找到"
- [ ] 即使测试套件为空，命令也能正常退出（exit 0）
