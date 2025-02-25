// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:uuid/uuid.dart';
import '../services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // List to store our tasks
  final List<Task> _tasks = [];

  // Controller for the text input
  final TextEditingController _textController = TextEditingController();

  // UUID generator
  final Uuid _uuid = const Uuid();

  // Storage service
  final _storageService = StorageService();

  // Save tasks to storage
  Future<void> _saveTasks() async {
    try {
      await _storageService.saveTasks(_tasks);
    } catch (e) {
      // ignore: avoid_print
      print('Error saving tasks: $e');
    }
  }

  // Add a new task
  void _addTask() {
    if (_textController.text.isNotEmpty) {
      setState(() {
        _tasks.add(
          Task(
            id: _uuid.v4(),
            title: _textController.text,
          ),
        );
        _textController.clear();
      });
      _saveTasks();
    }
  }

  // Toggle task completion
  void _toggleTask(String id) {
    setState(() {
      final taskIndex = _tasks.indexWhere((task) => task.id == id);
      if (taskIndex != -1) {
        _tasks[taskIndex].isCompleted = !_tasks[taskIndex].isCompleted;
      }
    });
    _saveTasks();
  }

  // Delete a task
  void _deleteTask(String id) {
    setState(() {
      _tasks.removeWhere((task) => task.id == id);
    });
    _saveTasks();
  }

  void _sortTasks() {
    setState(() {
      _tasks.sort((a, b) {
        if (a.isCompleted == b.isCompleted) {
          return b.createdAt.compareTo(a.createdAt); // Newest first
        }
        return a.isCompleted ? 1 : -1; // Completed tasks at the bottom
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _sortTasks,
            tooltip: 'Sort Tasks',
          ),
        ],
      ),
      body: Column(
        children: [
          // Input field for new tasks
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Add a new task',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _addTask,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),

          // Task list
          Expanded(
            child: _tasks.isEmpty
                ? const Center(child: Text('No tasks yet!'))
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      return ListTile(
                        leading: Checkbox(
                          value: task.isCompleted,
                          onChanged: (_) => _toggleTask(task.id),
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteTask(task.id),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
