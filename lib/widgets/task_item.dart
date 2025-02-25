// lib/widgets/task_item.dart
import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final Function(String) onToggle;
  final Function(String) onDelete;

  const TaskItem({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: task.isCompleted == 'true',
        onChanged: (_) => onToggle(task.id),
      ),
      title: Text(
        task.title,
        style: TextStyle(
          decoration:
              task.isCompleted == 'true' ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text(
        'Created: ${_formatDate(task.createdAt)}',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () => onDelete(task.id),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
