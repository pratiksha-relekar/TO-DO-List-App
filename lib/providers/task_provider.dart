import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  final String _storageKey = 'tasks';
  SharedPreferences? _prefs;

  List<Task> get tasks => _tasks;
  List<Task> get pendingTasks => _tasks.where((task) => task.status == TaskStatus.pending).toList();
  List<Task> get completedTasks => _tasks.where((task) => task.status == TaskStatus.completed).toList();

  TaskProvider() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadTasks();
  }

  void _loadTasks() {
    final String? tasksJson = _prefs?.getString(_storageKey);
    if (tasksJson != null) {
      final List<dynamic> decodedTasks = jsonDecode(tasksJson);
      _tasks = decodedTasks.map((task) => Task.fromJson(task)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveTasks() async {
    final String tasksJson = jsonEncode(_tasks.map((task) => task.toJson()).toList());
    await _prefs?.setString(_storageKey, tasksJson);
  }

  void addTask(Task task) {
    _tasks.add(task);
    _saveTasks();
    notifyListeners();
  }

  void updateTask(Task updatedTask) {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      _saveTasks();
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    _saveTasks();
    notifyListeners();
  }

  void toggleTaskStatus(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      final task = _tasks[index];
      final newStatus = task.status == TaskStatus.pending
          ? TaskStatus.completed
          : TaskStatus.pending;
      _tasks[index] = task.copyWith(
        status: newStatus,
        completedAt: newStatus == TaskStatus.completed ? DateTime.now() : null,
      );
      _saveTasks();
      notifyListeners();
    }
  }

  void reorderTasks(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final Task task = _tasks.removeAt(oldIndex);
    _tasks.insert(newIndex, task);
    _saveTasks();
    notifyListeners();
  }

  List<Task> getTasksByCategory(String category) {
    return _tasks.where((task) => task.category == category).toList();
  }

  List<Task> getTasksByDate(DateTime date) {
    return _tasks.where((task) => 
      task.dueDate != null &&
      task.dueDate!.year == date.year &&
      task.dueDate!.month == date.month &&
      task.dueDate!.day == date.day
    ).toList();
  }

  List<Task> getTasksByDateRange(DateTime start, DateTime end) {
    return _tasks.where((task) => 
      task.dueDate != null &&
      task.dueDate!.isAfter(start.subtract(const Duration(days: 1))) &&
      task.dueDate!.isBefore(end.add(const Duration(days: 1)))
    ).toList();
  }

  Map<String, int> getTaskStats() {
    final total = _tasks.length;
    final completed = completedTasks.length;
    final pending = pendingTasks.length;
    
    return {
      'total': total,
      'completed': completed,
      'pending': pending,
    };
  }
} 