import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_voce_chat/controller/todo_controllers/todo_controller.dart';
import 'package:my_voce_chat/types/todo_types/todo_types.dart';
import 'package:intl/intl.dart';
import 'package:my_voce_chat/views/todo_views/todo_list_tree_view/build_date_item.dart';

class TodoListTreeView extends StatefulWidget {
  const TodoListTreeView({super.key});

  @override
  State<TodoListTreeView> createState() => _TodoListTreeViewState();
}

class _TodoListTreeViewState extends State<TodoListTreeView> {
  final TodoController _todoController = Get.find();

  @override
  Widget build(BuildContext context) {
    // 今天的日期，用于标记时间线上的当前日期点
    final today = DateTime.now();
    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '我的任务',
          style: TextStyle(
            fontWeight: FontWeight.w600, // 稍微不那么粗
            color: Colors.black87, // 更柔和的黑色
          ),
        ),
        backgroundColor: Colors.white, // 扁平化设计，白色背景
        elevation: 0, // 完全移除阴影
        centerTitle: false, // 标题左对齐
        actions: [
          Obx(() => Switch(
                value: _todoController.isShowingAllTasks,
                onChanged: (value) {
                  if (value) {
                    _todoController.loadAllTasks();
                  } else {
                    _todoController.loadCurrentMonthTasks();
                  }
                },
                activeColor: Colors.blueAccent, // 更现代的蓝色
                inactiveThumbColor: Colors.grey.shade400,
                inactiveTrackColor: Colors.grey.shade200,
              )),
          const SizedBox(width: 8),
          Obx(() => Text(
                _todoController.isShowingAllTasks ? '全部任务' : '本月任务',
                style: TextStyle(
                    fontSize: 13, color: Colors.grey.shade600), // 文本颜色更柔和
              )),
          const SizedBox(width: 16),
        ],
      ),
      body: Obx(() {
        if (_todoController.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(
                  backgroundColor: Color(0xFFf1f2f6)));
        } else if (_todoController.taskGroups.isEmpty) {
          return const Center(child: Text('没有任务'));
        }
        return Container(
          decoration: BoxDecoration(color: Color(0xFFf1f2f6)),
          child: Stack(
            children: [
              // 垂直时间线 (背景线)
              Positioned(
                left: 32, // 时间线位置
                top: 0,
                bottom: 0,
                child: Container(
                  width: 1.5, // 细线
                  color: Colors.grey.shade300, // 更浅的灰色
                ),
              ),
              ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                itemCount: _todoController.taskGroups.length,
                itemBuilder: (context, index) {
                  return BuildDateItem(
                      taskGroup: _todoController.taskGroups[index],
                      isToday: todayString ==
                          _todoController.taskGroups[index].date);
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}
