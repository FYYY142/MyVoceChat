import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_voce_chat/controller/todo_controllers/todo_controller.dart';
import 'package:my_voce_chat/types/todo_types/todo_types.dart';
import 'package:my_voce_chat/views/todo_views/build_edit_from.dart';

class BuildCalendarItem extends StatelessWidget {
  final Task task;
  BuildCalendarItem({super.key, required this.task});

  final TodoController _todoController = Get.find<TodoController>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showCupertinoActionSheet(context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              offset: Offset(0, 1),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              task.type == 'task' ? Icons.task_alt : Icons.event,
              color:
                  task.type == 'task' ? Colors.blueAccent : Colors.purpleAccent,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task.description ?? '无描述',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF888888),
                    ),
                  ),
                ],
              ),
            ),
            if (task.type == 'task' && task.status != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(task.status!).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusTextMap[task.status!] ?? task.status!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _getStatusColor(task.status!),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 2. 实现 iOS 风格的动作表单方法
  void _showCupertinoActionSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        // 可以为菜单添加标题和消息
        title: Text('任务操作', style: TextStyle(color: Colors.grey.shade700)),
        message: Text('您要对 "${task.title}" 执行什么操作？'),
        // 定义操作按钮
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            child: const Text('编辑'),
            onPressed: () {
              Navigator.of(context).pop(); // 首先关闭菜单
              showModalBottomSheet(
                context: context,
                isScrollControlled: true, // 允许更高的弹窗
                backgroundColor: Colors.transparent, // 背景透明用于圆角
                builder: (context) => FractionallySizedBox(
                  heightFactor: 0.6, // ⬅️ 控制弹出高度（这里是 60% 屏幕）
                  child: BuildEditForm(
                    task: task,
                    isEdit: true,
                  ), // 可传 task: task
                ),
              ); // 然后执行编辑回调
            },
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true, // 将此操作标记为红色，表示有破坏性
            child: const Text('删除'),
            onPressed: () async {
              Navigator.of(context).pop(); // 首先关闭菜单
              // 调用已有的删除确认对话框
              final bool? confirmDelete =
                  await _showDeleteConfirmationDialog(context);
              if (confirmDelete == true) {
                _todoController.deleteTask(task.id); // 如果用户确认，执行删除回调
              }
            },
          ),
        ],
        // 单独的取消按钮，这是 iOS 的设计规范
        cancelButton: CupertinoActionSheetAction(
          child: const Text('取消'),
          onPressed: () {
            Navigator.of(context).pop(); // 关闭菜单
          },
        ),
      ),
    );
  }

  // 删除确认对话框 (保持不变，使用 Material 风格的 AlertDialog 也可以，兼容性很好)
  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Text('你确定要删除任务 "${task.title}" 吗？此操作无法撤销。'),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('删除'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
}

Color _getStatusColor(String status) {
  switch (status) {
    case 'completed':
      return Colors.green;
    case 'pending':
      return Colors.blue;
    case 'overdue':
      return Colors.red;
    case 'in_progress':
      return Colors.orange;
    default:
      return Colors.grey;
  }
}

// 如果想显示更友好状态文本喵，也可以加映射
const Map<String, String> _statusTextMap = {
  'completed': '已完成',
  'pending': '待处理',
  'overdue': '已逾期',
  'in_progress': '进行中',
};
