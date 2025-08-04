import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // 仍然需要导入 Material 以使用 Material 颜色或其他基本类型，但不再用于UI组件
import 'package:get/get.dart';
import 'package:my_voce_chat/controller/todo_controllers/todo_controller.dart';
import 'package:my_voce_chat/types/todo_types/todo_types.dart';

class BuildEditForm extends StatefulWidget {
  final Task? task;
  final bool isEdit;

  const BuildEditForm({super.key, this.task, required this.isEdit});

  @override
  State<BuildEditForm> createState() => _BuildEditFormState();
}

class _BuildEditFormState extends State<BuildEditForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descController;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  String _type = 'task';
  String _priority = 'medium';
  String _status = 'pending';

  final TodoController _todoController = Get.find<TodoController>();

  // 中文映射
  final Map<String, String> _typeMap = {
    'task': '任务',
    'event': '事件',
  };

  final Map<String, String> _priorityMap = {
    'low': '低',
    'medium': '中',
    'high': '高',
  };

  final Map<String, String> _statusMap = {
    'pending': '待处理',
    'in_progress': '进行中',
    'completed': '已完成',
    'overdue': '已逾期',
  };

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.task?.title ?? '',
    );
    _descController = TextEditingController(
      text: widget.task?.description ?? '',
    );

    _selectedDate = widget.task?.date != null && widget.task!.date!.isNotEmpty
        ? DateTime.tryParse(widget.task!.date!) ?? DateTime.now()
        : DateTime.now();

    _selectedTime = widget.task?.time != null && widget.task!.time!.isNotEmpty
        ? _parseTime(widget.task!.time!)
        : TimeOfDay.now();

    _type = widget.task?.type ?? 'task';
    _priority = widget.task?.priority ?? 'medium';
    _status = widget.task?.status ?? 'pending';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final formattedDate =
          "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
      final formattedTime =
          "${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}";

      final task = Task(
        // 根据 isEdit 和 widget.task 是否存在来决定 id
        id: widget.isEdit && widget.task != null // 如果是编辑模式且 widget.task 不为空
            ? widget.task!.id // 使用现有任务的 id
            : DateTime.now().millisecondsSinceEpoch.toString(), // 否则生成新的 id
        title: _titleController.text,
        description: _descController.text,
        date: formattedDate,
        time: formattedTime,
        type: _type,
        priority: _priority,
        status: _status,
        // 根据 isEdit 和 widget.task 是否存在来决定 createdAt
        createdAt:
            widget.isEdit && widget.task != null // 如果是编辑模式且 widget.task 不为空
                ? widget.task!.createdAt // 使用现有任务的 createdAt
                : DateTime.now().toIso8601String(), // 否则生成新的 createdAt
        updatedAt: DateTime.now().toIso8601String(),
      );

      if (widget.isEdit) {
        _todoController.updateTask(task.id, task);
      } else {
        _todoController.createTask(
            title: task.title,
            description: task.description,
            date: task.date,
            time: task.time,
            type: task.type,
            priority: task.priority,
            status: task.status);
      }

      Navigator.pop(context, task);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground, // iOS 风格的背景色
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.isEdit ? '编辑任务' : '创建任务'), // 根据编辑或创建显示不同标题
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Icon(CupertinoIcons.clear_thick), // 关闭按钮
        ),
      ),
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('标题', _titleController, required: true),
              _buildTextField('描述', _descController, maxLines: 3), // 增加描述的行数
              const SizedBox(height: 16),
              _buildCupertinoDateSelectionTile(),
              _buildCupertinoTimeSelectionTile(),
              const SizedBox(height: 16),
              _buildCupertinoPickerTile('类型', _typeMap[_type] ?? _type,
                  ['task', 'event'], (val) => setState(() => _type = val)),
              _buildCupertinoPickerTile(
                  '优先级',
                  _priorityMap[_priority] ?? _priority,
                  ['low', 'medium', 'high'],
                  (val) => setState(() => _priority = val)),
              _buildCupertinoPickerTile(
                  '状态',
                  _statusMap[_status] ?? _status,
                  ['pending', 'in_progress', 'completed', 'overdue'],
                  (val) => setState(() => _status = val)),
              const SizedBox(height: 30), // 增加底部按钮的间距
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: CupertinoButton.filled(
                  onPressed: _submitForm,
                  child: Text(widget.isEdit ? '更新任务' : '保存任务'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String placeholder, TextEditingController controller,
      {bool required = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 16, right: 16), // 调整间距
      child: CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        maxLines: maxLines,
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: CupertinoColors.systemGrey4, width: 0.5),
        ),
        // 验证逻辑需要手动在 submitForm 中处理或者使用自定义的验证方式
        // 这里为了保持Cupertino风格，不直接使用 TextFormField 的 validator 属性
        // 您可以在 _submitForm 中对 controller.text 进行手动验证
      ),
    );
  }

  // 使用自定义的列表项来模拟 Material 的 ListTile
  Widget _buildCupertinoListTile({
    required Widget title,
    Widget? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 22),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          border: Border(
            bottom: BorderSide(color: CupertinoColors.systemGrey5, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    DefaultTextStyle(
                      style: CupertinoTheme.of(context)
                          .textTheme
                          .textStyle
                          .copyWith(
                            color: CupertinoColors.systemGrey,
                            fontSize: 15,
                          ),
                      child: subtitle,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildCupertinoDateSelectionTile() {
    return _buildCupertinoListTile(
      title: const Text('日期',
          style: TextStyle(fontSize: 17, color: CupertinoColors.label)),
      subtitle: Text(
          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}'),
      trailing: const Icon(CupertinoIcons.calendar,
          color: CupertinoColors.systemGrey), // iOS 风格的日历图标
      onTap: () {
        _showCupertinoDatePicker();
      },
    );
  }

  Widget _buildCupertinoTimeSelectionTile() {
    return _buildCupertinoListTile(
      title: const Text('时间',
          style: TextStyle(fontSize: 17, color: CupertinoColors.label)),
      subtitle: Text(
          '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}'),
      trailing: const Icon(CupertinoIcons.time,
          color: CupertinoColors.systemGrey), // iOS 风格的时间图标
      onTap: () {
        _showCupertinoTimePicker();
      },
    );
  }

  // 模拟 iOS 的选择器，使用 CupertinoActionSheet 实现
  Widget _buildCupertinoPickerTile(String label, String value,
      List<String> options, Function(String) onChanged) {
    return _buildCupertinoListTile(
      title: Text(label,
          style: const TextStyle(fontSize: 17, color: CupertinoColors.label)),
      subtitle: Text(value),
      trailing: const Icon(CupertinoIcons.right_chevron,
          color: CupertinoColors.systemGrey),
      onTap: () {
        _showCupertinoPicker(label, value, options, onChanged);
      },
    );
  }

  void _showCupertinoDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          color: CupertinoColors.systemBackground,
          child: Column(
            children: [
              Container(
                color: CupertinoColors.systemBackground,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text('取消',
                          style: TextStyle(color: CupertinoColors.activeBlue)),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text('确定',
                          style: TextStyle(color: CupertinoColors.activeBlue)),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _selectedDate,
                  onDateTimeChanged: (date) {
                    setState(() => _selectedDate = date);
                  },
                  backgroundColor: CupertinoColors.systemBackground,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCupertinoTimePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          color: CupertinoColors.systemBackground,
          child: Column(
            children: [
              Container(
                color: CupertinoColors.systemBackground,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text('取消',
                          style: TextStyle(color: CupertinoColors.activeBlue)),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text('确定',
                          style: TextStyle(color: CupertinoColors.activeBlue)),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: DateTime(
                    0,
                    0,
                    0,
                    _selectedTime.hour,
                    _selectedTime.minute,
                  ),
                  use24hFormat: true,
                  onDateTimeChanged: (dt) {
                    setState(() => _selectedTime =
                        TimeOfDay(hour: dt.hour, minute: dt.minute));
                  },
                  backgroundColor: CupertinoColors.systemBackground,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCupertinoPicker(String title, String currentValue,
      List<String> options, Function(String) onChanged) {
    int selectedIndex = options.indexOf(currentValue);
    if (selectedIndex == -1) {
      selectedIndex = 0; // Fallback to first option if current value not found
    }

    // 根据标题选择对应的映射
    Map<String, String> displayMap = {};
    if (title == '类型') {
      displayMap = _typeMap;
    } else if (title == '优先级') {
      displayMap = _priorityMap;
    } else if (title == '状态') {
      displayMap = _statusMap;
    }

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text(title),
          actions: options.map((option) {
            return CupertinoActionSheetAction(
              child: Text(displayMap[option] ?? option),
              onPressed: () {
                onChanged(option);
                Navigator.pop(context);
              },
            );
          }).toList(),
          cancelButton: CupertinoActionSheetAction(
            child: const Text('取消'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }
}
