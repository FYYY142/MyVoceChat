// interface Task {
//   id: string                    // UUID主键
//   title: string                 // 标题（必填）
//   description?: string          // 描述（可选）
//   date: string                  // 日期 YYYY-MM-DD格式（必填）
//   time?: string                 // 时间 HH:mm格式（可选）
//   type: 'task' | 'event'        // 类型：任务或事件（默认：task）
//   priority?: 'low' | 'medium' | 'high'  // 优先级（仅任务，默认：medium）
//   status?: 'pending' | 'completed'      // 状态（仅任务，默认：pending）
//   created_at: string            // 创建时间（ISO 8601格式）
//   updated_at: string            // 更新时间（ISO 8601格式）
// }

class Task {
  final String id;
  final String title;
  final String? description;
  final String date;
  final String? time;
  final String type;
  final String? priority;
  final String? status;
  final String createdAt;
  final String updatedAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    this.time,
    required this.type,
    this.priority,
    this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  // 从JSON创建Task对象
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      date: json['date'] ?? '',
      time: json['time'],
      type: json['type'] ?? 'task',
      priority: json['priority'],
      status: json['status'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'time': time,
      'type': type,
      'priority': priority,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // 创建任务（用于POST请求）
  Map<String, dynamic> toCreateJson() {
    final json = <String, dynamic>{
      'title': title,
      'date': date,
      'type': type,
    };

    if (description != null) json['description'] = description;
    if (time != null) json['time'] = time;
    if (type == 'task') {
      json['priority'] = priority ?? 'medium';
      json['status'] = status ?? 'pending';
    }

    return json;
  }

  // 创建更新用的JSON（用于PUT请求）
  Map<String, dynamic> toUpdateJson() {
    final json = <String, dynamic>{};

    if (title.isNotEmpty) json['title'] = title;
    if (description != null) json['description'] = description;
    if (date.isNotEmpty) json['date'] = date;
    if (time != null) json['time'] = time;
    if (type.isNotEmpty) json['type'] = type;
    if (type == 'task') {
      if (priority != null) json['priority'] = priority;
      if (status != null) json['status'] = status;
    }

    return json;
  }

  // 复制并修改Task对象
  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? date,
    String? time,
    String? type,
    String? priority,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// 按日期分组的任务结构
class TaskGroup {
  final String date;
  final List<Task> tasks;

  TaskGroup({
    required this.date,
    required this.tasks,
  });

  // 从JSON创建TaskGroup对象
  factory TaskGroup.fromJson(Map<String, dynamic> json) {
    return TaskGroup(
      date: json['date'] ?? '',
      tasks: (json['tasks'] as List<dynamic>?)
              ?.map((task) => Task.fromJson(task))
              .toList() ??
          [],
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'tasks': tasks.map((task) => task.toJson()).toList(),
    };
  }
}
