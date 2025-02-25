// lib/widgets/task_form.dart
import 'package:flutter/material.dart';

class TaskForm extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const TaskForm({
    super.key,
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Add a new task',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => onSubmit(),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: onSubmit,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
