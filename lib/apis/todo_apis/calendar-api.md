# 日历任务管理 API 文档

## 概述

日历任务管理系统提供完整的RESTful API，支持任务和事件的增删改查操作。

**基础URL**: `http://localhost:3000/api/tasks`

## 数据模型

### Task/Event 数据结构

```typescript
interface Task {
  id: string                    // UUID主键
  title: string                 // 标题（必填）
  description?: string          // 描述（可选）
  date: string                  // 日期 YYYY-MM-DD格式（必填）
  time?: string                 // 时间 HH:mm格式（可选）
  type: 'task' | 'event'        // 类型：任务或事件（默认：task）
  priority?: 'low' | 'medium' | 'high'  // 优先级（仅任务，默认：medium）
  status?: 'pending' | 'completed'      // 状态（仅任务，默认：pending）
  created_at: string            // 创建时间（ISO 8601格式）
  updated_at: string            // 更新时间（ISO 8601格式）
}
```

### 类型说明

#### 任务 (Task)
- `type: 'task'`
- 必须有 `priority` 和 `status` 字段
- 可以标记完成状态
- 用于需要完成的工作项

#### 事件 (Event)
- `type: 'event'`
- `priority` 和 `status` 字段为 `null`
- 不能标记完成状态
- 用于时间提醒和记录

## API 接口

### 1. 获取任务/事件列表

**GET** `/api/tasks`

获取指定日期范围内的所有任务和事件。

#### 请求参数

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| start_date | string | 否 | 开始日期 (YYYY-MM-DD) |
| end_date | string | 否 | 结束日期 (YYYY-MM-DD) |

#### 请求示例

```bash
GET /api/tasks?start_date=2025-01-01&end_date=2025-01-31
```

#### 响应示例

```json
[
  {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "title": "团队会议",
    "description": "讨论项目进度和下周计划",
    "date": "2025-01-15",
    "time": "10:00",
    "type": "task",
    "priority": "high",
    "status": "pending",
    "created_at": "2025-01-10T08:00:00.000Z",
    "updated_at": "2025-01-10T08:00:00.000Z"
  },
  {
    "id": "123e4567-e89b-12d3-a456-426614174001",
    "title": "生日聚会",
    "description": "小明的生日聚会",
    "date": "2025-01-15",
    "time": "19:00",
    "type": "event",
    "priority": null,
    "status": null,
    "created_at": "2025-01-10T08:00:00.000Z",
    "updated_at": "2025-01-10T08:00:00.000Z"
  }
]
```

### 2. 创建任务/事件

**POST** `/api/tasks`

创建新的任务或事件。

#### 请求体

```json
{
  "title": "任务标题",           // 必填
  "description": "任务描述",     // 可选
  "date": "2025-01-15",        // 必填，YYYY-MM-DD格式
  "time": "10:00",             // 可选，HH:mm格式
  "type": "task",              // 可选，默认为"task"
  "priority": "high",          // 任务必填，事件忽略
  "status": "pending"          // 任务必填，事件忽略
}
```

#### 任务创建示例

```json
{
  "title": "完成项目报告",
  "description": "整理本月项目进度报告",
  "date": "2025-01-20",
  "time": "14:00",
  "type": "task",
  "priority": "high"
}
```

#### 事件创建示例

```json
{
  "title": "公司年会",
  "description": "2025年度总结大会",
  "date": "2025-01-25",
  "time": "18:00",
  "type": "event"
}
```

#### 响应示例

```json
{
  "success": true,
  "message": "任务创建成功",
  "data": {
    "id": "123e4567-e89b-12d3-a456-426614174002",
    "title": "完成项目报告",
    "description": "整理本月项目进度报告",
    "date": "2025-01-20",
    "time": "14:00",
    "type": "task",
    "priority": "high",
    "status": "pending",
    "created_at": "2025-01-15T10:30:00.000Z",
    "updated_at": "2025-01-15T10:30:00.000Z"
  }
}
```

### 3. 更新任务/事件

**PUT** `/api/tasks/:id`

更新指定ID的任务或事件。

#### 路径参数

| 参数 | 类型 | 说明 |
|------|------|------|
| id | string | 任务/事件的UUID |

#### 请求体

```json
{
  "title": "更新后的标题",      // 可选
  "description": "更新后的描述", // 可选
  "date": "2025-01-21",        // 可选
  "time": "15:00",             // 可选
  "type": "task",              // 可选
  "priority": "medium",        // 可选（仅任务）
  "status": "completed"        // 可选（仅任务）
}
```

#### 响应示例

```json
{
  "success": true,
  "message": "任务更新成功",
  "data": {
    "id": "123e4567-e89b-12d3-a456-426614174002",
    "title": "更新后的标题",
    "description": "更新后的描述",
    "date": "2025-01-21",
    "time": "15:00",
    "type": "task",
    "priority": "medium",
    "status": "completed",
    "created_at": "2025-01-15T10:30:00.000Z",
    "updated_at": "2025-01-15T11:45:00.000Z"
  }
}
```

### 4. 删除任务/事件

**DELETE** `/api/tasks/:id`

删除指定ID的任务或事件。

#### 路径参数

| 参数 | 类型 | 说明 |
|------|------|------|
| id | string | 任务/事件的UUID |

#### 响应示例

```json
{
  "success": true,
  "message": "任务删除成功"
}
```

### 5. 获取单个任务/事件

**GET** `/api/tasks/:id`

获取指定ID的任务或事件详情。

#### 路径参数

| 参数 | 类型 | 说明 |
|------|------|------|
| id | string | 任务/事件的UUID |

#### 响应示例

```json
{
  "success": true,
  "data": {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "title": "团队会议",
    "description": "讨论项目进度和下周计划",
    "date": "2025-01-15",
    "time": "10:00",
    "type": "task",
    "priority": "high",
    "status": "pending",
    "created_at": "2025-01-10T08:00:00.000Z",
    "updated_at": "2025-01-10T08:00:00.000Z"
  }
}
```

## 错误响应

所有API在出错时都会返回统一的错误格式：

```json
{
  "success": false,
  "message": "错误描述",
  "error": "详细错误信息"
}
```

### 常见错误码

| HTTP状态码 | 说明 |
|------------|------|
| 400 | 请求参数错误 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |

### 错误示例

```json
{
  "success": false,
  "message": "标题和日期为必填字段"
}
```

```json
{
  "success": false,
  "message": "任务不存在"
}
```

```json
{
  "success": false,
  "message": "优先级必须是 low, medium 或 high"
}
```

## 数据验证规则

### 必填字段
- `title`: 字符串，不能为空
- `date`: 字符串，YYYY-MM-DD格式

### 可选字段
- `description`: 字符串，最大200字符
- `time`: 字符串，HH:mm格式
- `type`: 枚举值，'task' 或 'event'，默认 'task'

### 任务特有字段
- `priority`: 枚举值，'low'、'medium' 或 'high'，默认 'medium'
- `status`: 枚举值，'pending' 或 'completed'，默认 'pending'

### 事件特有规则
- 事件的 `priority` 和 `status` 字段会被忽略或设为 `null`

## 使用建议

### 1. 获取月度数据
```javascript
// 获取2025年1月的所有数据
const response = await fetch('/api/tasks?start_date=2025-01-01&end_date=2025-01-31');
const tasks = await response.json();
```

### 2. 创建任务
```javascript
const taskData = {
  title: '完成功能开发',
  description: '实现用户登录功能',
  date: '2025-01-20',
  time: '09:00',
  type: 'task',
  priority: 'high'
};

const response = await fetch('/api/tasks', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(taskData)
});
```

### 3. 创建事件
```javascript
const eventData = {
  title: '团建活动',
  description: '公司团建聚餐',
  date: '2025-01-25',
  time: '18:00',
  type: 'event'
};

const response = await fetch('/api/tasks', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(eventData)
});
```

### 4. 更新任务状态
```javascript
const response = await fetch(`/api/tasks/${taskId}`, {
  method: 'PUT',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ status: 'completed' })
});
```

### 5. 删除项目
```javascript
const response = await fetch(`/api/tasks/${taskId}`, {
  method: 'DELETE'
});
```

## 数据库表结构

```sql
CREATE TABLE calendar_tasks (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    date DATE NOT NULL,
    time TIME,
    type VARCHAR(10) DEFAULT 'task' CHECK (type IN ('task', 'event')),
    priority VARCHAR(10) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'completed')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## 索引优化

- `idx_calendar_tasks_date`: 按日期查询优化
- `idx_calendar_tasks_type`: 按类型查询优化
- `idx_calendar_tasks_status`: 按状态查询优化
- `idx_calendar_tasks_priority`: 按优先级查询优化

这个API设计完全支持移动端开发，提供了灵活的数据查询和管理功能！