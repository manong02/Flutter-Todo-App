// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:uuid/uuid.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Task> _tasks = [];
  final TextEditingController _textController = TextEditingController();
  final Uuid _uuid = const Uuid();
  final _firebaseService = FirebaseService();
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final tasks = await _firebaseService.loadTasks();
      setState(() {
        _tasks.clear();
        _tasks.addAll(tasks);
      });
      await _notificationService.fetchTodosAndNotify();
    } catch (e) {
      print('Error loading tasks: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      return ListTile(
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration:
                                task.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        leading: Checkbox(
                          value: task.isCompleted,
                          onChanged: (bool? value) {
                            _toggleTask(task.id);
                          },
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteTask(task.id),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Add a new task',
                    ),
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addTask,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
      _notificationService.fetchTodosAndNotify();
    }
  }

  void _toggleTask(String id) {
    setState(() {
      final taskIndex = _tasks.indexWhere((task) => task.id == id);
      if (taskIndex != -1) {
        _tasks[taskIndex].isCompleted = !_tasks[taskIndex].isCompleted;
      }
    });
    _saveTasks();
    _notificationService.fetchTodosAndNotify();
  }

  void _deleteTask(String id) {
    setState(() {
      _tasks.removeWhere((task) => task.id == id);
    });
    _saveTasks();
    _notificationService.fetchTodosAndNotify();
  }

  Future<void> _saveTasks() async {
    try {
      await _firebaseService.saveTasks(_tasks);
    } catch (e) {
      print('Error saving tasks: $e');
    }
  }
}
