import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_voce_chat/controller/todo_controllers/todo_controller.dart';
import 'package:my_voce_chat/views/todo_views/todo_list_tree_view/todo_list_tree_view.dart';
import 'package:my_voce_chat/views/todo_views/todo_calendar_view/todo_calendar_view.dart';

class TodoView extends StatefulWidget {
  const TodoView({super.key});

  @override
  State<TodoView> createState() => _TodoViewState();
}

class _TodoViewState extends State<TodoView> {
  final TodoController _todoController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('事项清单'),
        actions: [
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('树'),
              ),
              Obx(
                () => SizedBox(
                  height: 32,
                  child: ToggleButtons(
                    isSelected: [
                      _todoController.isTreeView.value,
                      !_todoController.isTreeView.value,
                    ],
                    onPressed: (int index) {
                      _todoController.toggleView(index);
                    },
                    borderRadius: BorderRadius.circular(8),
                    children: const [
                      Icon(Icons.account_tree, size: 18),
                      Icon(Icons.calendar_month, size: 18),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('日历'),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
          child: Obx(() {
            return _todoController.isTreeView.value
                ? const TodoListTreeView()
                : const TodoCalendarView();
          }),
          onRefresh: () => _todoController.loadAllTasks()),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateTaskDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateTaskDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final dateController = TextEditingController();
    final timeController = TextEditingController();

    // 设置默认日期为今天
    final today = DateTime.now();
    dateController.text =
        '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    String selectedType = 'task';
    String selectedPriority = 'medium';

    Get.dialog(
      AlertDialog(
        title: const Text('创建新任务'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: '标题 *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: '描述',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: dateController,
                      decoration: const InputDecoration(
                        labelText: '日期 *',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: today,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          dateController.text =
                              '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: timeController,
                      decoration: const InputDecoration(
                        labelText: '时间',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          timeController.text =
                              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('类型: '),
                  DropdownButton<String>(
                    value: selectedType,
                    items: const [
                      DropdownMenuItem(value: 'task', child: Text('任务')),
                      DropdownMenuItem(value: 'event', child: Text('事件')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedType = value;
                        });
                      }
                    },
                  ),
                  if (selectedType == 'task') ...[
                    const SizedBox(width: 16),
                    const Text('优先级: '),
                    DropdownButton<String>(
                      value: selectedPriority,
                      items: const [
                        DropdownMenuItem(value: 'low', child: Text('低')),
                        DropdownMenuItem(value: 'medium', child: Text('中')),
                        DropdownMenuItem(value: 'high', child: Text('高')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedPriority = value;
                          });
                        }
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty) {
                Get.snackbar('错误', '标题不能为空');
                return;
              }

              final success = await _todoController.createTask(
                title: titleController.text.trim(),
                description: descriptionController.text.trim().isEmpty
                    ? null
                    : descriptionController.text.trim(),
                date: dateController.text,
                time: timeController.text.trim().isEmpty
                    ? null
                    : timeController.text.trim(),
                type: selectedType,
                priority: selectedType == 'task' ? selectedPriority : null,
              );

              if (success) {
                Navigator.pop(context);
                Get.snackbar('成功', '任务创建成功');
              } else {
                Get.snackbar('错误', '任务创建失败');
              }
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }
}
