# Design Document: <Project Name>

## System Overview

<!-- 一段话描述系统的目标、核心价值和边界 -->

**Problem**: <what problem this system solves>
**Solution**: <how this system solves it>
**Out of scope**: <what this system explicitly does NOT do>

---

## Architecture

<!-- 系统组件划分和依赖关系，用文字或 ASCII 图表示 -->

```
[Component A] → [Component B] → [Component C]
      ↓
[Component D]
```

**Key components**:
- **ComponentA**: <responsibility>
- **ComponentB**: <responsibility>

---

## API Design

<!-- 对外暴露的接口定义。如果是 REST API，每个端点一个小节 -->

### `POST /api/v1/<resource>`

**Purpose**: <what this endpoint does>

**Request**:
```json
{
  "field1": "string",
  "field2": 0
}
```

**Response** (200):
```json
{
  "id": "string",
  "field1": "string",
  "created_at": "ISO 8601"
}
```

**Error responses**:
- `400 Bad Request`: validation failed
- `404 Not Found`: resource not found

<!-- Repeat for each endpoint -->

---

## Data Model

<!-- 数据实体定义，包含字段、类型、约束 -->

### Entity: `<EntityName>`

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | `string` | PK, UUID | Primary key |
| `name` | `string` | NOT NULL, max 255 | Display name |
| `created_at` | `datetime` | NOT NULL | Creation timestamp |

**Relationships**:
- `EntityA` has many `EntityB` (via `entity_a_id` FK)

---

## Non-Functional Requirements

| Requirement | Target | Notes |
|-------------|--------|-------|
| Response time (p95) | < 200ms | For read endpoints |
| Availability | 99.9% | Monthly SLA |
| Max concurrent users | 1000 | Initial launch target |

---

## Open Questions

<!-- 尚未决定的设计问题，每条附上决策截止日期或依赖条件 -->

- [ ] Should we use optimistic or pessimistic locking for concurrent updates? (decide before F003)
- [ ] Authentication: JWT or session cookies? (decide before F001)
