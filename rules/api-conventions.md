---
paths:
  - "src/api/**/*.ts"
  - "src/routes/**/*.ts"
  - "app/api/**/*.ts"
---

# API 开发规范

## 端点设计

- RESTful 命名：资源用复数名词（`/users`、`/posts`）
- 操作通过 HTTP 方法区分（GET 查询、POST 创建、PUT 全量更新、PATCH 部分更新、DELETE 删除）
- 版本化：`/api/v1/...`

## 输入验证

- 所有请求参数必须在端点入口处验证
- 使用 Zod / Pydantic / Go validator 等类型安全的验证库
- 验证失败返回 `400 Bad Request` + 具体错误信息

## 响应格式

```typescript
// 成功响应
{ "data": <payload> }

// 错误响应
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "用户可读的错误描述",
    "details": {}  // 可选，调试信息
  }
}
```

## 错误状态码

| 状态码 | 场景 |
|-------|------|
| 400 | 请求参数错误 |
| 401 | 未认证 |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 409 | 资源冲突 |
| 422 | 业务逻辑错误 |
| 500 | 服务器内部错误 |

## 安全

- 每个端点独立验证权限，不依赖路由层面的全局守卫
- 不在错误响应中暴露内部实现细节
- 参考 `context/security-checklist.md`
