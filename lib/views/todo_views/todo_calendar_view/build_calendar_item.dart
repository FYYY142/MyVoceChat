import 'package:flutter/material.dart';
import 'package:my_voce_chat/types/todo_types/todo_types.dart';

class BuildCalendarItem extends StatelessWidget {
  final Task task;
  const BuildCalendarItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
