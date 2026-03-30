# 测试策略

## 核心原则

**测试是不可协商的约束**（来自 Anthropic 工程实践）：
- 不删除或注释掉已有测试
- 不修改 assertion 来让测试通过（除非需求确实变更）
- 不因为「时间紧」跳过测试
- 新功能必须附带测试，否则视为未完成

## 测试分层

```
E2E Tests（端到端）
    ↑
Integration Tests（集成）
    ↑
Unit Tests（单元）← 大多数测试在这里
```

- 单元测试：纯函数、业务逻辑、工具函数
- 集成测试：模块间交互、数据库操作、外部服务 mock
- E2E 测试：关键用户路径，用浏览器自动化（Playwright）

## 各语言测试工具

| 语言 | 测试框架 | Mock | 覆盖率 |
|------|---------|------|--------|
| TypeScript | Vitest / Jest | vi.mock / jest.mock | vitest --coverage |
| Python | pytest | pytest-mock / unittest.mock | pytest-cov |
| Go | go test | testify/mock | go test -cover |
| Java | JUnit 5 | Mockito | JaCoCo |

## 测试命名规范

```typescript
// TypeScript - describe/it 结构
describe('UserService', () => {
  describe('createUser', () => {
    it('should return created user when valid input', () => {})
    it('should throw ValidationError when email is invalid', () => {})
  })
})
```

```python
# Python - 函数命名
def test_create_user_returns_user_when_valid_input(): ...
def test_create_user_raises_validation_error_when_email_invalid(): ...
```

```java
// Java - JUnit 5 嵌套类风格
@DisplayName("UserService")
class UserServiceTest {
    @Nested
    @DisplayName("createUser")
    class CreateUser {
        @Test
        void shouldReturnCreatedUserWhenValidInput() {}

        @Test
        void shouldThrowValidationExceptionWhenEmailIsInvalid() {}
    }
}
```

## 测试数据管理

- 使用 factory 函数或 fixtures 生成测试数据，不硬编码
- 测试之间相互独立，不依赖执行顺序
- 数据库测试：每个测试前清理，使用事务回滚

## 浏览器自动化（E2E）

对于 Web 应用，使用 Playwright 做端到端验证：
- 关键用户流程必须有 E2E 覆盖（登录、核心业务动作）
- E2E 跑在 CI 中，失败时阻断合并
- 参考 `mcps/README.md` 中的 Playwright MCP 配置

## CI 集成

- 每次 commit 触发单元测试
- PR 合并前触发完整测试套件（含集成测试）
- 覆盖率下降时给出警告（不强制阻断，但需关注）

## Eval 可靠性（Agentic 场景）

来源：Anthropic《Quantifying infrastructure noise in agentic coding evals》（2026-03）

Agent 的 eval 结果本身是有噪声的。基础设施因素（网络延迟、超时、资源竞争、并发冲突）会导致相同 prompt 在相同代码下产生不同的 pass/fail 结果，这种噪声有时足以淹没模型能力的真实差异。

**实践规则：**

- 关键行为（尤其是 Agent 决策路径、工具调用链）至少跑 3 次，取多数结果，不信任单次结论
- 区分两类失败：
  - `flaky`：偶发、不可复现 → 基础设施噪声，不视为 regression
  - `regression`：稳定复现 → 真实问题，必须修复后才能合并
- 新增 eval 在纳入 CI 前，先做「基线噪声测量」：在干净状态下跑 5 次，记录通过率，低于 90% 的 eval 不应作为合并 gate
- 高价值但高噪声的 eval 可以移出 PR gate，改为定期跑（每日/每周），单独追踪趋势

**eval 质量分级参考：**

| 通过率（干净状态） | 适合做 | 不适合做 |
|--------------------|--------|---------|
| ≥ 95% | PR gate | — |
| 80–95% | 定期监控 | PR gate |
| < 80% | 问题排查信号 | 任何自动决策 |
