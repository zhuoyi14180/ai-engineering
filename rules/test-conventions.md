---
paths:
  - "**/*.test.ts"
  - "**/*.test.tsx"
  - "**/*.spec.ts"
  - "**/*.test.py"
  - "**/*_test.go"
---

# 测试文件规范

## 文件组织

- 测试文件紧邻被测文件（`foo.ts` 对应 `foo.test.ts`）
- E2E 测试放在 `e2e/` 或 `tests/` 目录
- 测试工具/fixtures 放在 `tests/helpers/` 或 `conftest.py`

## 测试结构

每个测试必须符合 **AAA 模式**：
```
Arrange  → 准备测试数据和环境
Act      → 执行被测行为
Assert   → 验证结果
```

## 命名规范

```typescript
// 描述行为，不描述实现
describe('UserService', () => {
  it('should throw NotFoundError when user does not exist', () => {})
  it('should return user with hashed password excluded', () => {})
})
```

```python
# Python: 函数名即文档
def test_create_user_raises_not_found_when_user_does_not_exist(): ...
```

## 禁止项

- 不在测试中使用 `console.log` 调试（清理后再提交）
- 不跳过测试（`it.skip`、`pytest.mark.skip`）而不注明原因和 issue
- 不使用 `setTimeout` 或 `sleep` 做等待（用 `waitFor` 等断言式等待）
- 不依赖测试执行顺序

## Mock 原则

- 只 mock 外部依赖（网络、数据库、文件系统、时间）
- 不 mock 被测单元的内部逻辑
- 使用 factory 函数生成测试数据，不硬编码
