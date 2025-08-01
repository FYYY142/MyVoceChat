import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_voce_chat/controller/todo_controllers/todo_controller.dart';
import 'package:my_voce_chat/types/todo_types/todo_types.dart';
import 'package:my_voce_chat/views/todo_views/build_edit_from.dart';
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
        backgroundColor: Colors.white,
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
                    selectedColor: Colors.green,
                    fillColor: Colors.green.withOpacity(0.2),
                    color: Colors.green,
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
          backgroundColor: Colors.white,
          color: Colors.green,
          child: Obx(() {
            return _todoController.isTreeView.value
                ? const TodoListTreeView()
                : const TodoCalendarView();
          }),
          onRefresh: () => _todoController.loadCurrentMonthTasks()),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 138, 203, 236),
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true, // 允许更高的弹窗
          backgroundColor: Colors.transparent, // 背景透明用于圆角
          builder: (context) => FractionallySizedBox(
            heightFactor: 0.6, // ⬅️ 控制弹出高度（这里是 60% 屏幕）
            child: BuildEditForm(isEdit: false), // 可传 task: task
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
