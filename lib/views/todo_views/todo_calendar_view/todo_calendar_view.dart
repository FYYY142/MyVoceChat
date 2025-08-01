import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_voce_chat/views/todo_views/todo_calendar_view/build_calendar_item.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:my_voce_chat/controller/todo_controllers/todo_controller.dart';
import 'package:my_voce_chat/types/todo_types/todo_types.dart';

DateTime normalizeDate(DateTime date) {
  return DateTime.utc(date.year, date.month, date.day);
}

class TodoCalendarView extends StatefulWidget {
  const TodoCalendarView({super.key});

  @override
  State<TodoCalendarView> createState() => _TodoCalendarViewState();
}

class _TodoCalendarViewState extends State<TodoCalendarView> {
  final TodoController _todoController = Get.find();

  late DateTime _focusedDay;
  late DateTime? _selectedDay;
  late final ValueNotifier<List<Task>> _selectedDayTasksAndEvents;

  @override
  void initState() {
    super.initState();
    _focusedDay = normalizeDate(DateTime.now());
    _selectedDay = _focusedDay;
    _selectedDayTasksAndEvents = ValueNotifier(_getEventsForDay(_selectedDay!));

    _todoController.tasks.listen((_) {
      _selectedDayTasksAndEvents.value = _getEventsForDay(_selectedDay!);
    });
    _todoController.events.listen((_) {
      _selectedDayTasksAndEvents.value = _getEventsForDay(_selectedDay!);
    });
  }

  @override
  void dispose() {
    _selectedDayTasksAndEvents.dispose();
    super.dispose();
  }

  List<Task> _getEventsForDay(DateTime day) {
    final normalizedDay = normalizeDate(day);
    final List<Task> allDayEvents = _todoController.getAllTasks().where((task) {
      try {
        final taskDate = normalizeDate(DateTime.parse(task.date));
        return isSameDay(taskDate, normalizedDay);
      } catch (e) {
        print('解析任务日期失败: ${task.date} - $e');
        return false;
      }
    }).toList();
    return allDayEvents;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = normalizeDate(selectedDay);
        _focusedDay = normalizeDate(focusedDay);
      });
      _selectedDayTasksAndEvents.value = _getEventsForDay(_selectedDay!);
    }
  }

  // 构建事件标记的小组件 (保持不变)
  Widget _buildEventsMarker(List<Task> events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: events.any((e) => e.type == 'event')
            ? Colors.purple
            : Colors.blue.shade700,
      ),
      width: 18.0,
      height: 18.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的日历'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 将 TableCalendar 包裹在 Expanded 中
          Expanded(
            // <--- 这里是关键修改
            flex: 4, // 日历占据 3 份空间
            child: Obx(() {
              if (_todoController.isLoading.value) {
                return const Center(
                    child: CircularProgressIndicator()); // 加载指示器居中显示
              }
              return TableCalendar<Task>(
                firstDay: normalizeDate(DateTime.utc(2025, 7, 1)),
                lastDay: normalizeDate(DateTime.utc(2025, 12, 31)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                locale: 'zh_CN',

                calendarFormat: CalendarFormat.month, // 默认月视图
                onDaySelected: _onDaySelected,
                onPageChanged: (focusedDay) {
                  _focusedDay = normalizeDate(focusedDay);
                  _todoController.loadTasksByMonth(
                      _focusedDay.year, _focusedDay.month);
                },

                eventLoader: _getEventsForDay,
                calendarBuilders: CalendarBuilders(
                  selectedBuilder: (context, day, focusedDay) {
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                  todayBuilder: (context, day, focusedDay) {
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade300,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(
                            color: Colors.black87, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                  markerBuilder: (context, day, events) {
                    if (events.isNotEmpty) {
                      return Positioned(
                        right: 1,
                        bottom: 1,
                        child: _buildEventsMarker(events),
                      );
                    }
                    return null;
                  },
                ),
              );
            }),
          ),
          const SizedBox(height: 12.0),
          // 任务列表也使用 Expanded，并分配剩余空间
          Expanded(
            // <--- 这里也保持 Expanded
            flex: 2, // 任务列表占据 2 份空间
            child: ValueListenableBuilder<List<Task>>(
              valueListenable: _selectedDayTasksAndEvents,
              builder: (context, tasksAndEvents, _) {
                if (_todoController.isLoading.value) {
                  // 任务列表也显示加载
                  return const Center(child: CircularProgressIndicator());
                }
                if (tasksAndEvents.isEmpty) {
                  return Center(
                    child: Text(
                      _selectedDay != null
                          ? '${_selectedDay!.month}月${_selectedDay!.day}日 暂无任务/事件'
                          : '请选择日期查看任务和事件',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: tasksAndEvents.length,
                  itemBuilder: (context, index) {
                    final task = tasksAndEvents[index];
                    return BuildCalendarItem(task: task);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// TodoController 和 Task/TaskGroup 保持不变，请确保路径正确