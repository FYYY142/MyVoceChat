import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:my_voce_chat/apis/todo_apis/todo_apis.dart';
import 'package:my_voce_chat/types/todo_types/todo_types.dart';

class TodoController extends GetxController {
  final RxBool isTreeView = true.obs;

  // 任务数据
  final RxList<Task> tasks = <Task>[].obs;
  final RxList<Task> events = <Task>[].obs;

  // 按日期分组的任务数据
  final RxList<TaskGroup> taskGroups = <TaskGroup>[].obs;

  // 加载状态
  final RxBool isLoading = false.obs;
  final RxBool isCreating = false.obs;
  final RxBool isUpdating = false.obs;
  final RxBool isDeleting = false.obs;

  // 错误信息
  final RxString errorMessage = ''.obs;

  // 当前选中的任务
  final Rx<Task?> selectedTask = Rx<Task?>(null);

  // 当前查看的日期范围
  final RxString currentStartDate = ''.obs;
  final RxString currentEndDate = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCurrentMonthTasks();
  }

  void toggleView(int index) {
    isTreeView.value = index == 0;
  }

  // MARK: - 数据加载方法

  /// 加载当前月份的任务
  Future<void> loadCurrentMonthTasks() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final now = DateTime.now();
      final taskList = await TodoApi.getTasksByMonth(now.year, now.month);

      _separateTasksAndEvents(taskList);
      _updateDateRange(now.year, now.month);
      processTaskGroups();
      Fluttertoast.showToast(msg: '任务加载成功');
    } catch (e) {
      errorMessage.value = '加载任务失败: $e';
      Fluttertoast.showToast(msg: '加载任务失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 加载指定月份的任务
  Future<void> loadTasksByMonth(int year, int month) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final taskList = await TodoApi.getTasksByMonth(year, month);
      _separateTasksAndEvents(taskList);
      _updateDateRange(year, month);
      processTaskGroups();
      Fluttertoast.showToast(msg: '${year}年${month}月任务加载成功');
    } catch (e) {
      errorMessage.value = '加载任务失败: $e';
      Fluttertoast.showToast(msg: '加载任务失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 加载指定日期的任务
  Future<void> loadTasksByDate(String date) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final taskList = await TodoApi.getTasksByDate(date);
      _separateTasksAndEvents(taskList);
      currentStartDate.value = date;
      currentEndDate.value = date;
      processTaskGroups();
      Fluttertoast.showToast(msg: '$date 任务加载成功');
    } catch (e) {
      errorMessage.value = '加载任务失败: $e';
      Fluttertoast.showToast(msg: '加载任务失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 加载所有任务
  Future<void> loadAllTasks() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final taskList = await TodoApi.getTaskList();
      _separateTasksAndEvents(taskList);
      currentStartDate.value = '';
      currentEndDate.value = '';
      processTaskGroups();
      Fluttertoast.showToast(msg: '所有任务加载成功');
    } catch (e) {
      errorMessage.value = '加载任务失败: $e';
      Fluttertoast.showToast(msg: '加载任务失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// MARK: 创建新任务
  Future<bool> createTask({
    required String title,
    String? description,
    required String date,
    String? time,
    String type = 'task',
    String? priority,
    String? status,
  }) async {
    isCreating.value = true;
    errorMessage.value = '';

    try {
      final newTask = await TodoApi.createTaskSimple(
        title: title,
        description: description,
        date: date,
        time: time,
        type: type,
        priority: priority,
        status: status,
      );

      if (newTask != null) {
        Fluttertoast.showToast(msg: '创建成功!');
        // 直接插入到本地状态
        if (newTask.type == 'task') {
          tasks.add(newTask);
        } else if (newTask.type == 'event') {
          events.add(newTask);
        }
        processTaskGroups();
        return true;
      } else {
        Fluttertoast.showToast(msg: '创建任务失败');
        errorMessage.value = '创建任务失败';
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: '创建任务失败');
      errorMessage.value = '创建任务失败: $e';
      return false;
    } finally {
      isCreating.value = false;
    }
  }

  /// MARK: 更新任务
  Future<bool> updateTask(String taskId, Map<String, dynamic> data) async {
    isUpdating.value = true;
    errorMessage.value = '';

    try {
      final result = await TodoApi.updateTask(taskId, data);
      if (result != null) {
        Fluttertoast.showToast(msg: '任务更新成功');
        // 直接替换本地状态中的任务
        tasks.removeWhere((task) => task.id == result.id);
        events.removeWhere((event) => event.id == result.id);

        if (result.type == 'task') {
          tasks.add(result);
        } else if (result.type == 'event') {
          events.add(result);
        }

        processTaskGroups();
        return true;
      } else {
        errorMessage.value = '更新任务失败';
        Fluttertoast.showToast(msg: '更新任务失败');
        return false;
      }
    } catch (e) {
      errorMessage.value = '更新任务失败: $e';
      Fluttertoast.showToast(msg: '更新任务失败: $e');
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  /// MARK: 删除任务
  Future<bool> deleteTask(String taskId) async {
    isDeleting.value = true;
    errorMessage.value = '';

    try {
      final success = await TodoApi.deleteTask(taskId);
      if (success) {
        Fluttertoast.showToast(msg: '删除成功');
        // 直接从本地列表移除
        tasks.removeWhere((task) => task.id == taskId);
        events.removeWhere((event) => event.id == taskId);

        // 如果删除的是当前选中的任务，清空选中状态
        if (selectedTask.value?.id == taskId) {
          selectedTask.value = null;
        }

        processTaskGroups();
        return true;
      } else {
        errorMessage.value = '删除任务失败';
        return false;
      }
    } catch (e) {
      errorMessage.value = '删除任务失败: $e';
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  /// 获取任务详情
  Future<Task?> getTaskDetail(String taskId) async {
    try {
      final task = await TodoApi.getTask(taskId);
      if (task != null) {
        selectedTask.value = task;
        Fluttertoast.showToast(msg: '任务详情加载成功');
      } else {
        Fluttertoast.showToast(msg: '任务不存在');
      }
      return task;
    } catch (e) {
      errorMessage.value = '获取任务详情失败: $e';
      Fluttertoast.showToast(msg: '获取任务详情失败: $e');
      return null;
    }
  }

  // MARK: - 任务选择和状态管理

  /// 选择任务
  void selectTask(Task task) {
    selectedTask.value = task;
  }

  /// 清空选中的任务
  void clearSelectedTask() {
    selectedTask.value = null;
  }

  /// 清空错误信息
  void clearError() {
    errorMessage.value = '';
  }

  // MARK: - 数据查询方法

  /// 获取所有任务（包括任务和事件）
  List<Task> getAllTasks() {
    return [...tasks, ...events];
  }

  /// 获取待完成的任务
  List<Task> getPendingTasks() {
    return tasks.where((task) => task.status == 'pending').toList();
  }

  /// 获取已完成的任务
  List<Task> getCompletedTasks() {
    return tasks.where((task) => task.status == 'completed').toList();
  }

  /// 获取高优先级任务
  List<Task> getHighPriorityTasks() {
    return tasks.where((task) => task.priority == 'high').toList();
  }

  /// 检查是否显示所有任务
  bool get isShowingAllTasks {
    return currentStartDate.value.isEmpty && currentEndDate.value.isEmpty;
  }

  // MARK: - 数据处理和工具方法

  /// 刷新数据
  Future<void> refreshData() async {
    try {
      if (currentStartDate.value.isNotEmpty &&
          currentEndDate.value.isNotEmpty) {
        if (currentStartDate.value == currentEndDate.value) {
          await loadTasksByDate(currentStartDate.value);
        } else {
          final startDate = DateTime.parse(currentStartDate.value);
          await loadTasksByMonth(startDate.year, startDate.month);
        }
      } else {
        await loadCurrentMonthTasks();
      }
      Fluttertoast.showToast(msg: '数据刷新成功');
    } catch (e) {
      Fluttertoast.showToast(msg: '数据刷新失败: $e');
    }
  }

  // MARK: - 私有辅助方法

  /// 处理任务分组
  void processTaskGroups() {
    final allTasks = [...tasks, ...events];
    final Map<String, List<Task>> groupedTasks = {};

    for (final task in allTasks) {
      final date = task.date;
      if (!groupedTasks.containsKey(date)) {
        groupedTasks[date] = [];
      }
      groupedTasks[date]!.add(task);
    }

    final groups = groupedTasks.entries.map((entry) {
      return TaskGroup(
        date: entry.key,
        tasks: entry.value,
      );
    }).toList();

    groups.sort((a, b) => b.date.compareTo(a.date));
    taskGroups.assignAll(groups);
  }

  /// 分离任务和事件
  void _separateTasksAndEvents(List<Task> taskList) {
    tasks.clear();
    events.clear();

    for (final task in taskList) {
      if (task.type == 'task') {
        tasks.add(task);
      } else if (task.type == 'event') {
        events.add(task);
      }
    }
  }

  /// 更新日期范围
  void _updateDateRange(int year, int month) {
    currentStartDate.value =
        '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-01';
    currentEndDate.value =
        '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-31';
  }
}
