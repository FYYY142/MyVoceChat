import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_voce_chat/types/todo_types/todo_types.dart';
import 'package:my_voce_chat/utils/http_util/http_util.dart';
import 'package:my_voce_chat/utils/alert_util/alert_util.dart';

class TodoApi {
  static const String baseUrl = 'https://fyyy-express.vercel.app/api/tasks';

  /// 获取任务/事件列表
  /// [startDate] 开始日期 (YYYY-MM-DD)
  /// [endDate] 结束日期 (YYYY-MM-DD)
  static Future<List<Task>> getTaskList({
    String? startDate,
    String? endDate,
  }) async {
    try {
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
    } catch (e) {
      AlertUtil.showErrorDialog(
        message: '获取任务列表失败：$e',
        title: '网络请求错误',
      );
      return [];
    }
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
      AlertUtil.showErrorDialog(
        message: '创建任务失败：$e\n\n任务信息：${task.toString()}',
        title: '创建任务错误',
      );
      return null;
    }
  }

  /// 更新任务/事件
  static Future<Task?> updateTask(
      String taskId, Map<String, dynamic> data) async {
    try {
      final response = await HttpUtil.to.put(
        '$baseUrl/$taskId',
        data: data,
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return Task.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      AlertUtil.showErrorDialog(
        message: '更新任务失败：$e\n\n任务ID：$taskId\n更新数据：${data.toString()}',
        title: '更新任务错误',
      );
      return null;
    }
  }

  /// 删除任务/事件
  static Future<bool> deleteTask(String taskId) async {
    try {
      final response = await HttpUtil.to.delete('$baseUrl/$taskId');
      return response.data['success'] == true;
    } catch (e) {
      AlertUtil.showErrorDialog(
        message: '删除任务失败：$e\n\n任务ID：$taskId',
        title: '删除任务错误',
      );
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
      AlertUtil.showErrorDialog(
        message: '获取任务详情失败：$e\n\n任务ID：$taskId',
        title: '获取任务错误',
      );
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
    try {
      final data = <String, dynamic>{
        'title': title,
        'date': date,
        'type': type,
      };

      if (description != null) data['description'] = description;
      if (time != null) data['time'] = time;
      if (type == 'task') {
        data['priority'] = priority ?? 'medium';
        data['status'] = status ?? 'pending';
      }

      final response = await HttpUtil.to.post(baseUrl, data: data);

      if (response.data['success'] == true && response.data['data'] != null) {
        return Task.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      AlertUtil.showErrorDialog(
        message: '创建任务失败：$e\n\n任务标题：$title\n日期：$date',
        title: '创建任务错误',
      );
      return null;
    }
  }
}
