# 个人信息与沟通偏好

- 语言：中文交流，代码、变量名、注释用英文
- 风格：简洁精准，不加 emoji，避免冗余解释
- 对话格式：直接给出结论，必要时附原因；不用问候语开头

# 工作流规范

## 任务启动

- 非平凡任务（超过 3 步或改动超过 2 个文件）先进入 Plan 模式
- 长期任务（多会话）必须在项目根目录维护 `progress.json`
- 每个会话开始前执行状态检查：当前目录、git log、progress.json 内容

## 代码修改原则

- 先读再改：绝不对未读的文件提修改建议
- 最小改动：不添加未被明确要求的功能、注释、错误处理
- 优先复用：找到现有实现再考虑新写
- 不过度工程化：三行重复代码优于过早抽象

## 测试约束（硬性规则）

- 不允许删除或注释掉测试用例
- 不允许为通过测试而修改 assertion（除非需求变更）
- 新功能必须附带测试

## Git 规范

- 非平凡的 push、force push、reset --hard 等操作执行前须确认
- commit 格式和分支策略详见 @context/git-workflow.md

# 编码偏好

## 常用语言

TypeScript、Python、Go、Java，具体选择视项目技术栈而定。

## TypeScript / JavaScript

- 使用 ES modules（import/export），不用 CommonJS（require）
- 函数式优于命令式（在合理范围内）
- 类型定义明确，避免 `any`

## Python

- 优先 Python 3.10+，使用类型注解
- 工具链：uv（包管理）、ruff（lint/format）、pytest（测试）

## Go

- 遵循 `gofmt` 格式化
- error 处理：显式检查，`errors.Is`/`errors.As` 做类型判断
- 接口定义在消费者侧（最小接口原则）

## Java

- 目标 Java 17+（LTS 版本）
- 构建工具：Maven 或 Gradle，视项目而定
- 格式化：google-java-format 或 Spotless
- 测试：JUnit 5 + Mockito

## 通用

- 错误处理：只在系统边界（用户输入、外部 API）做防御；内部逻辑信任约束
- 不写仅注释掉、添加 `_unused` 前缀或重导出的向后兼容 hack

# 安全约束

- 不生成可能包含命令注入、SQL 注入、XSS 的代码，发现后立即修复
- 不将密钥、token、密码写入代码或 git 追踪的文件

@context/security-checklist.md

# AI 工程化上下文

@context/ai-engineering-principles.md

# 常用资源引用

@context/coding-standards.md
@context/git-workflow.md
@context/testing-patterns.md
