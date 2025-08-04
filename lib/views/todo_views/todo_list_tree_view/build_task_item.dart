import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // 1. 导入 Cupertino 库
import 'package:get/get.dart';
import 'package:my_voce_chat/controller/todo_controllers/todo_controller.dart';
import 'package:my_voce_chat/types/todo_types/todo_types.dart';
import 'package:my_voce_chat/views/todo_views/build_edit_from.dart'; // 使用您项目中的 Task 定义

class BuildTaskItem extends StatelessWidget {
  final Task task;
  // final VoidCallback onEdit;
  // final VoidCallback onDelete;
  final TodoController _todoController = Get.find<TodoController>();

  BuildTaskItem({
    super.key,
    required this.task,
    // required this.onEdit,
    // required this.onDelete,
  });

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

  @override
  Widget build(BuildContext context) {
    // 3. 将 GestureDetector 的事件改为 onTap 并调用新方法
    return InkWell(
      onTap: () {
        _showCupertinoActionSheet(context);
      },
      child: Padding(
        padding: const EdgeInsets.only(
            left: 48.0, right: 16.0, bottom: 8.0), // 任务项左边距，使其在时间线右侧对齐
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: task.type == 'task'
                  ? const AssetImage('assets/images/bg_task_item_day.png')
                  : const AssetImage('assets/images/bg_event_item_day.png'),
              fit: BoxFit.cover,
              opacity: 0.3,
            ),
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.blueGrey[900],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (task.time != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(
                            task.time!,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                      if (task.description != null)
                        Text(
                          task.description ?? "",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                if (task.type == 'task' && task.status != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: _getStatusColor(task.status!).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        _statusTextMap[task.status!] ?? task.status!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(task.status!),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 根据状态返回不同的颜色 (保持不变)
Color _getStatusColor(String status) {
  switch (status) {
    case '已完成':
      return Colors.green.shade600;
    case '进行中':
      return Colors.blue.shade600;
    case '未开始':
      return Colors.orange.shade600;
    case '已延期':
      return Colors.red.shade600;
    case '已看':
      return Colors.purple.shade600;
    case '未看':
      return Colors.deepOrange.shade600;
    default:
      return Colors.grey.shade600;
  }
}

// 如果想显示更友好状态文本喵，也可以加映射
const Map<String, String> _statusTextMap = {
  'completed': '已完成',
  'pending': '待处理'
};
