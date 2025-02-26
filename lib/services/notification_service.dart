import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:js' as js;

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _webNotificationsInitialized = false;

  Future<void> initialize() async {
    if (kIsWeb) {
      await _initializeWebNotifications();
    } else {
      await _initializeNativeNotifications();
    }
  }

  Future<void> _initializeWebNotifications() async {
    if (!_webNotificationsInitialized) {
      try {
        // Check if the browser supports notifications
        final notificationSupported = js.context.hasProperty('Notification');
        if (notificationSupported) {
          // Request permission
          final result = await js.context['Notification'].callMethod('requestPermission');
          _webNotificationsInitialized = result == 'granted';
        }
      } catch (e) {
        print('Error initializing web notifications: $e');
      }
    }
  }

  Future<void> _initializeNativeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> fetchTodosAndNotify() async {
    final List<String> todos = [];
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .where('isCompleted', isEqualTo: false)  // Only fetch incomplete tasks
        .get();

    for (var doc in querySnapshot.docs) {
      todos.add(doc['title']);
    }

    if (todos.isNotEmpty) {
      await showTodoNotification(todos);
    }
  }

  Future<void> showTodoNotification(List<String> todos) async {
    if (todos.isEmpty) return;

    String todoList = todos.asMap().entries.map((entry) {
      return '${entry.key + 1}. ${entry.value}';
    }).join('\n');

    if (kIsWeb) {
      _showWebNotification(todoList, todos.length);
    } else {
      await _showNativeNotification(todoList, todos);
    }
  }

  void _showWebNotification(String todoList, int count) {
    if (!_webNotificationsInitialized) return;

    try {
      // Create notification using JavaScript
      js.context.callMethod('eval', ['''
        new Notification("Your To-Do List ($count items)", {
          body: "$todoList",
          icon: "/icons/icon-192.png"
        });
      ''']);
    } catch (e) {
      print('Error showing web notification: $e');
    }
  }

  Future<void> _showNativeNotification(String todoList, List<String> todos) async {
    final List<AndroidNotificationAction> actions = todos.asMap().entries.map((entry) {
      return AndroidNotificationAction(
        'MARK_DONE_${entry.key}',
        'Complete #${entry.key + 1}',
      );
    }).toList();

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'todo_channel',
      'To-Do Notifications',
      importance: Importance.high,
      priority: Priority.high,
      actions: actions,
      styleInformation: BigTextStyleInformation(todoList),
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0,
      'Your To-Do List (${todos.length} items)',
      todoList,
      platformChannelSpecifics,
    );
  }

  void handleNotificationAction(String actionId) {
    if (actionId.startsWith('MARK_DONE_')) {
      final index = int.tryParse(actionId.split('_').last);
      if (index != null) {
        markTaskAsDone(index);
      }
    }
  }

  void markTaskAsDone(int index) async {
    final QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance
            .collection('tasks')
            .where('isCompleted', isEqualTo: false)
            .get();

    if (querySnapshot.docs.length > index) {
      final taskDoc = querySnapshot.docs[index];
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(taskDoc.id)
          .update({'isCompleted': true});

      fetchTodosAndNotify();
    }
  }
}
