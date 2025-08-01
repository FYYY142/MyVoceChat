import 'package:flutter/material.dart';
import 'package:my_voce_chat/types/todo_types/todo_types.dart';
import 'package:my_voce_chat/views/todo_views/todo_list_tree_view/build_task_item.dart';

class BuildDateItem extends StatelessWidget {
  final TaskGroup taskGroup;
  final bool isToday;
  const BuildDateItem(
      {super.key, required this.taskGroup, required this.isToday});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
              left: 16.0, top: 12.0, bottom: 8.0), // 调整日期外边距
          child: Row(
            children: [
              // 时间线上的点
              Container(
                width: 10, // 缩小圆点
                height: 10,
                decoration: BoxDecoration(
                  color: isToday
                      ? Colors.deepOrangeAccent
                      : Colors.blueGrey.shade400, // 今天的点更醒目
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2), // 边框效果
                ),
              ),
              const SizedBox(width: 12), // 点与日期背景容器的间距
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5), // 日期背景填充
                decoration: BoxDecoration(
                  color: isToday
                      ? Colors.deepOrangeAccent.withOpacity(0.15)
                      : Colors.blueGrey.shade100, // 日期背景色
                  borderRadius: BorderRadius.circular(8), // 圆角
                ),
                child: Text(
                  taskGroup.date,
                  style: TextStyle(
                    fontSize: 16, // 缩小字体
                    fontWeight: FontWeight.bold,
                    color: isToday
                        ? Colors.deepOrange
                        : Colors.blueGrey.shade700, // 字体颜色
                  ),
                ),
              ),
            ],
          ),
        ),
        // 动态生成任务项
        ...taskGroup.tasks
            .map((task) => BuildTaskItem(
                  task: task,
                ))
            .toList(),
        const SizedBox(height: 0), // 日期组之间增加间距，可根据需求调整
      ],
    );
  }
}
