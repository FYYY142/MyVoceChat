import 'package:flutter/material.dart';
import 'package:my_voce_chat/types/todo_types/todo_types.dart';

class BuildTaskItem extends StatelessWidget {
  final Task task;
  const BuildTaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 48.0, right: 16.0, bottom: 8.0), // 任务项左边距，使其在时间线右侧对齐
      child: Container(
        // 使用Container代替Card，移除阴影
        decoration: BoxDecoration(
          image: DecorationImage(
            image: task.type == 'task'
                ? AssetImage('assets/images/bg_task_item_day.png')
                : AssetImage('assets/images/bg_event_item_day.png'),
            fit: BoxFit.cover, // 可以是 cover, contain, fill 等
            opacity: 0.3, // 调整背景图透明度
          ),
          color: Colors.white,
          borderRadius: BorderRadius.circular(10), // 更圆润的边角
          border: Border.all(color: Colors.grey.shade200, width: 1), // 细边框替代阴影
        ),
        child: Padding(
          padding: const EdgeInsets.all(6), // 内部填充
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
                        fontSize: 15, // 缩小标题字体
                        fontWeight: FontWeight.w500,
                        color: Colors.blueGrey[900],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (task.time != null) // 如果有时间跨度，显示时间
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
                          fontSize: 12, // 缩小描述字体
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (task.type == 'task' && task.status != null) // 只有事项才显示状态标签
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3), // 缩小标签填充
                    decoration: BoxDecoration(
                      color: _getStatusColor(task.status!)
                          .withOpacity(0.12), // 更浅的背景色
                      borderRadius: BorderRadius.circular(5), // 略微减小圆角
                    ),
                    child: Text(
                      task.status!,
                      style: TextStyle(
                        fontSize: 11, // 缩小状态字体
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
    );
  }
}

// 根据状态返回不同的颜色
Color _getStatusColor(String status) {
  switch (status) {
    case '已完成':
      return Colors.green.shade600; // 更深的绿色
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
