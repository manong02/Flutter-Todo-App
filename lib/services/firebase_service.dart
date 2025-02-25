// lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'tasks';

  // Save tasks to Firestore
  Future<void> saveTasks(List<Task> tasks) async {
    try {
      // Get a reference to the tasks collection
      final tasksRef = _firestore.collection(_collection);

      // Delete all existing tasks
      final existingTasks = await tasksRef.get();
      final batch = _firestore.batch();
      for (var doc in existingTasks.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Add all current tasks in a batch
      final newBatch = _firestore.batch();
      for (var task in tasks) {
        final docRef = tasksRef.doc(task.id);
        newBatch.set(docRef, {
          'id': task.id,
          'title': task.title,
          'isCompleted': task.isCompleted,
          'createdAt': task.createdAt.millisecondsSinceEpoch,
        });
      }
      await newBatch.commit();
    } catch (e) {
      print('Error saving tasks to Firestore: $e');
      rethrow;
    }
  }

  // Load tasks from Firestore
  Future<List<Task>> loadTasks() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Task(
          id: data['id'] as String,
          title: data['title'] as String,
          isCompleted: data['isCompleted'] as bool,
          createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int),
        );
      }).toList();
    } catch (e) {
      print('Error loading tasks from Firestore: $e');
      return [];
    }
  }
}
