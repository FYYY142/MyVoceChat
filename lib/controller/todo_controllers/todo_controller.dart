import 'package:get/get.dart';
import 'package:my_voce_chat/apis/todo_apis/todo_apis.dart';
import 'package:my_voce_chat/types/todo_types/todo_types.dart';

class TodoController extends GetxController {
  final RxBool isTreeView = true.obs;
  final RxBool isEditViewShow = false.obs;

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
    // 初始化时加载当前月份的任务
    loadCurrentMonthTasks();
  }

  void toggleView(int index) {
    isTreeView.value = index == 0;
  }

  /// 加载当前月份的任务
  Future<void> loadCurrentMonthTasks() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final now = DateTime.now();
      final taskList = await TodoApi.getTasksByMonth(now.year, now.month);

      // 分离任务和事件
      tasks.clear();
      events.clear();

      for (final task in taskList) {
        if (task.type == 'task') {
          tasks.add(task);
        } else if (task.type == 'event') {
          events.add(task);
        }
      }

      // 更新日期范围
      currentStartDate.value =
          '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-01';
      currentEndDate.value =
          '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-31';

      // 处理任务分组
      processTaskGroups();
    } catch (e) {
      errorMessage.value = '加载任务失败: $e';
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

      // 分离任务和事件
      tasks.clear();
      events.clear();

      for (final task in taskList) {
        if (task.type == 'task') {
          tasks.add(task);
        } else if (task.type == 'event') {
          events.add(task);
        }
      }

      // 更新日期范围
      currentStartDate.value =
          '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-01';
      currentEndDate.value =
          '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-31';

      // 处理任务分组
      processTaskGroups();
    } catch (e) {
      errorMessage.value = '加载任务失败: $e';
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

      // 分离任务和事件
      tasks.clear();
      events.clear();

      for (final task in taskList) {
        if (task.type == 'task') {
          tasks.add(task);
        } else if (task.type == 'event') {
          events.add(task);
        }
      }

      // 更新日期范围
      currentStartDate.value = date;
      currentEndDate.value = date;

      // 处理任务分组
      processTaskGroups();
    } catch (e) {
      errorMessage.value = '加载任务失败: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// MARK: 加载所有任务（不限制时间范围）
  Future<void> loadAllTasks() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final taskList = await TodoApi.getTaskList();

      // 分离任务和事件
      tasks.clear();
      events.clear();

      for (final task in taskList) {
        if (task.type == 'task') {
          tasks.add(task);
        } else if (task.type == 'event') {
          events.add(task);
        }
      }

      // 清空日期范围，表示显示所有任务
      currentStartDate.value = '';
      currentEndDate.value = '';

      // 处理任务分组
      processTaskGroups();
    } catch (e) {
      errorMessage.value = '加载任务失败: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// 创建新任务
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
        // 添加到对应的列表中
        if (newTask.type == 'task') {
          tasks.add(newTask);
        } else if (newTask.type == 'event') {
          events.add(newTask);
        }

        // 处理任务分组
        processTaskGroups();
        return true;
      } else {
        errorMessage.value = '创建任务失败';
        return false;
      }
    } catch (e) {
      errorMessage.value = '创建任务失败: $e';
      return false;
    } finally {
      isCreating.value = false;
    }
  }

  /// 更新任务
  Future<bool> updateTask(String taskId, Task updatedTask) async {
    isUpdating.value = true;
    errorMessage.value = '';

    try {
      final result = await TodoApi.updateTask(taskId, updatedTask);

      if (result != null) {
        // 更新本地数据
        _updateLocalTask(result);

        // 处理任务分组
        processTaskGroups();
        return true;
      } else {
        errorMessage.value = '更新任务失败';
        return false;
      }
    } catch (e) {
      errorMessage.value = '更新任务失败: $e';
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  /// 删除任务
  Future<bool> deleteTask(String taskId) async {
    isDeleting.value = true;
    errorMessage.value = '';

    try {
      final success = await TodoApi.deleteTask(taskId);

      if (success) {
        // 从本地列表中移除
        tasks.removeWhere((task) => task.id == taskId);
        events.removeWhere((event) => event.id == taskId);

        // 如果删除的是当前选中的任务，清空选中状态
        if (selectedTask.value?.id == taskId) {
          selectedTask.value = null;
        }

        // 处理任务分组
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

  /// 更新任务状态
  Future<bool> updateTaskStatus(String taskId, String status) async {
    isUpdating.value = true;
    errorMessage.value = '';

    try {
      final result = await TodoApi.updateTaskStatus(taskId, status);

      if (result != null) {
        // 更新本地数据
        _updateLocalTask(result);

        // 处理任务分组
        processTaskGroups();
        return true;
      } else {
        errorMessage.value = '更新任务状态失败';
        return false;
      }
    } catch (e) {
      errorMessage.value = '更新任务状态失败: $e';
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  /// 更新任务优先级
  Future<bool> updateTaskPriority(String taskId, String priority) async {
    isUpdating.value = true;
    errorMessage.value = '';

    try {
      final result = await TodoApi.updateTaskPriority(taskId, priority);

      if (result != null) {
        // 更新本地数据
        _updateLocalTask(result);

        // 处理任务分组
        processTaskGroups();
        return true;
      } else {
        errorMessage.value = '更新任务优先级失败';
        return false;
      }
    } catch (e) {
      errorMessage.value = '更新任务优先级失败: $e';
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  /// 获取任务详情
  Future<Task?> getTaskDetail(String taskId) async {
    try {
      final task = await TodoApi.getTask(taskId);
      if (task != null) {
        selectedTask.value = task;
      }
      return task;
    } catch (e) {
      errorMessage.value = '获取任务详情失败: $e';
      return null;
    }
  }

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

  /// 检查是否显示所有任务（通过检查日期范围是否为空）
  bool get isShowingAllTasks {
    return currentStartDate.value.isEmpty && currentEndDate.value.isEmpty;
  }

  /// 更新本地任务数据
  void _updateLocalTask(Task updatedTask) {
    // 从原列表中移除
    tasks.removeWhere((task) => task.id == updatedTask.id);
    events.removeWhere((event) => event.id == updatedTask.id);

    // 添加到对应的新列表中
    if (updatedTask.type == 'task') {
      tasks.add(updatedTask);
    } else if (updatedTask.type == 'event') {
      events.add(updatedTask);
    }

    // 如果更新的是当前选中的任务，更新选中状态
    if (selectedTask.value?.id == updatedTask.id) {
      selectedTask.value = updatedTask;
    }
  }

  /// 刷新数据
  Future<void> refreshData() async {
    if (currentStartDate.value.isNotEmpty && currentEndDate.value.isNotEmpty) {
      if (currentStartDate.value == currentEndDate.value) {
        // 如果是同一天，加载指定日期的任务
        await loadTasksByDate(currentStartDate.value);
      } else {
        // 否则加载日期范围的任务
        final startDate = DateTime.parse(currentStartDate.value);
        await loadTasksByMonth(startDate.year, startDate.month);
      }
    } else {
      // 默认加载当前月份
      await loadCurrentMonthTasks();
    }
  }

  /// 处理任务分组
  void processTaskGroups() {
    final allTasks = [...tasks, ...events];

    // 按日期分组
    final Map<String, List<Task>> groupedTasks = {};

    for (final task in allTasks) {
      final date = task.date;
      if (!groupedTasks.containsKey(date)) {
        groupedTasks[date] = [];
      }
      groupedTasks[date]!.add(task);
    }

    // 转换为 TaskGroup 列表并按日期排序
    final groups = groupedTasks.entries.map((entry) {
      return TaskGroup(
        date: entry.key,
        tasks: entry.value,
      );
    }).toList();

    // 按日期排序（最新的在前）
    groups.sort((a, b) => b.date.compareTo(a.date));

    taskGroups.assignAll(groups);
  }
}
