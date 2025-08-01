import 'package:my_voce_chat/types/todo_types/todo_types.dart';
import 'package:my_voce_chat/utils/http_util/http_util.dart';

class TodoApi {
  static const String baseUrl = 'http://192.168.31.88:3000/api/tasks';

  /// 获取任务/事件列表
  /// [startDate] 开始日期 (YYYY-MM-DD)
  /// [endDate] 结束日期 (YYYY-MM-DD)
  static Future<List<Task>> getTaskList({
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;

    final response = await HttpUtil.to.get(
      baseUrl,
      params: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response.data is List) {
      return (response.data as List)
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// 创建任务/事件
  static Future<Task?> createTask(Task task) async {
    try {
      final response = await HttpUtil.to.post(
        baseUrl,
        data: task.toCreateJson(),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return Task.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      print('创建任务失败: $e');
      return null;
    }
  }

  /// 更新任务/事件
  static Future<Task?> updateTask(String taskId, Task task) async {
    try {
      final response = await HttpUtil.to.put(
        '$baseUrl/$taskId',
        data: task.toUpdateJson(),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return Task.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      print('更新任务失败: $e');
      return null;
    }
  }

  /// 删除任务/事件
  static Future<bool> deleteTask(String taskId) async {
    try {
      final response = await HttpUtil.to.delete('$baseUrl/$taskId');
      return response.data['success'] == true;
    } catch (e) {
      print('删除任务失败: $e');
      return false;
    }
  }

  /// 获取单个任务/事件
  static Future<Task?> getTask(String taskId) async {
    try {
      final response = await HttpUtil.to.get('$baseUrl/$taskId');

      if (response.data['success'] == true && response.data['data'] != null) {
        return Task.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      print('获取任务失败: $e');
      return null;
    }
  }

  /// 获取指定月份的任务列表
  static Future<List<Task>> getTasksByMonth(int year, int month) async {
    final startDate =
        '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-01';
    final endDate =
        '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-31';

    return getTaskList(startDate: startDate, endDate: endDate);
  }

  /// 获取指定日期的任务列表
  static Future<List<Task>> getTasksByDate(String date) async {
    return getTaskList(startDate: date, endDate: date);
  }

  /// 创建任务（简化方法）
  static Future<Task?> createTaskSimple({
    required String title,
    String? description,
    required String date,
    String? time,
    String type = 'task',
    String? priority,
    String? status,
  }) async {
    final task = Task(
      id: '', // 创建时不需要ID
      title: title,
      description: description,
      date: date,
      time: time,
      type: type,
      priority: priority,
      status: status,
      createdAt: '',
      updatedAt: '',
    );

    return createTask(task);
  }

  /// 更新任务状态
  static Future<Task?> updateTaskStatus(String taskId, String status) async {
    final task = Task(
      id: taskId,
      title: '',
      date: '',
      type: 'task',
      status: status,
      createdAt: '',
      updatedAt: '',
    );

    return updateTask(taskId, task);
  }

  /// 更新任务优先级
  static Future<Task?> updateTaskPriority(
      String taskId, String priority) async {
    final task = Task(
      id: taskId,
      title: '',
      date: '',
      type: 'task',
      priority: priority,
      createdAt: '',
      updatedAt: '',
    );

    return updateTask(taskId, task);
  }
}
