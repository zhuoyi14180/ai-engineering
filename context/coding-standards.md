# 编码规范

## TypeScript / JavaScript

### 模块系统
- 使用 ES modules（`import`/`export`），不使用 CommonJS（`require`/`module.exports`）
- 具名导出优先于默认导出（便于重构和 IDE 支持）
- 解构导入：`import { foo, bar } from './module'`

### 类型系统
- 避免 `any`；必要时用 `unknown` 替代
- 接口优于类型别名（`interface` vs `type`）描述对象结构
- 函数参数和返回值必须有明确类型，不依赖推导

### 代码风格
- 函数式优于命令式（合理范围内）
- 纯函数优于有副作用的函数
- 短路求值和可选链：`obj?.foo ?? defaultVal`
- 避免嵌套超过 3 层；提前 return 代替 if-else 嵌套

### 工具链
- 包管理：pnpm 优先，其次 npm
- 格式化：Prettier（默认配置）
- Lint：ESLint + typescript-eslint
- 测试：Vitest（Node）或 Jest

---

## Python

### 版本与环境
- 目标 Python 3.10+
- 包管理：uv（`uv add`、`uv run`）
- 虚拟环境：由 uv 自动管理（`.venv/`）

### 代码风格
- 使用类型注解（PEP 484）
- dataclass 或 Pydantic model 代替裸 dict 传参
- 上下文管理器处理资源（`with` 语句）
- f-string 格式化，不用 `%` 或 `.format()`

### 工具链
- 格式化 + Lint：ruff（`ruff format`、`ruff check`）
- 类型检查：mypy 或 pyright
- 测试：pytest + pytest-cov

---

## Go

### 代码风格
- 遵循 `gofmt` 格式化（提交前必须运行）
- error 处理：显式检查，不忽略；`errors.Is`/`errors.As` 做判断
- 接口定义在消费者侧（最小接口原则）
- 避免 init()；避免全局可变状态

### 工具链
- 格式化：gofmt / goimports
- Lint：golangci-lint
- 测试：go test（table-driven tests）

---

## Java

### 版本与环境
- 目标 Java 17+（LTS）；新项目优先 Java 21
- 构建工具：Maven 或 Gradle，视项目技术栈和团队约定而定

### 代码风格
- 遵循 Google Java Style Guide
- 格式化：google-java-format 或 Spotless 插件（集成在构建工具中）
- 泛型类型参数必须明确，不用原始类型（`List` → `List<String>`）
- 优先不可变对象：`final` 字段，record 类型（Java 16+）
- 用 `Optional` 表达可空返回值，不返回 `null`

### 工具链
- 格式化：google-java-format
- Lint / 静态分析：Checkstyle + SpotBugs
- 测试：JUnit 5 + Mockito + AssertJ
- 覆盖率：JaCoCo

---

## 通用原则

- **可读性优先**：代码是写给人读的，机器执行是其次
- **命名清晰**：变量名表达意图，不用缩写（除非约定俗成如 `ctx`、`err`、`i`）
- **函数单一职责**：一个函数做一件事，不超过 30 行为参考上限
- **注释说「为什么」，不说「是什么」**：代码本身说明是什么，注释解释为何这样做
- **不写防御性代码处理不可能发生的情况**：只在系统边界（用户输入、外部 API 响应）做验证
