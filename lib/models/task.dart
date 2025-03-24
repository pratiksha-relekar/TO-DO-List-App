import 'package:uuid/uuid.dart';

enum TaskPriority { low, medium, high }
enum TaskStatus { pending, completed }

class Task {
  final String id;
  String title;
  String description;
  DateTime? dueDate;
  TaskPriority priority;
  TaskStatus status;
  List<String> tags;
  String category;
  bool isRecurring;
  DateTime createdAt;
  DateTime? completedAt;

  Task({
    String? id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.pending,
    this.tags = const [],
    this.category = 'Default',
    this.isRecurring = false,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        this.createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
    List<String>? tags,
    String? category,
    bool? isRecurring,
    DateTime? completedAt,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      isRecurring: isRecurring ?? this.isRecurring,
      createdAt: createdAt,
    )..completedAt = completedAt ?? this.completedAt;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority.index,
      'status': status.index,
      'tags': tags,
      'category': category,
      'isRecurring': isRecurring,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      priority: TaskPriority.values[json['priority']],
      status: TaskStatus.values[json['status']],
      tags: List<String>.from(json['tags']),
      category: json['category'],
      isRecurring: json['isRecurring'],
      createdAt: DateTime.parse(json['createdAt']),
    )..completedAt = json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null;
  }
} 