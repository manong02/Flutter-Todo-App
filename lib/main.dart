// lib/main.dart
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize shared preferences
  await SharedPreferences.getInstance();

  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  // Create a Firebase Analytics instance
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Add analytics navigation observer
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      // Rest of your app setup
      // ...
    );
  }
}
