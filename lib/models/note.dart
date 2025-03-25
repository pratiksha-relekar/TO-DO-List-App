import 'package:flutter/material.dart';

class Note {
  final String id;
  String title;
  String content;
  DateTime createdAt;
  bool isPinned;
  bool isFavorite;
  Color color;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.isPinned = false,
    this.isFavorite = false,
    this.color = Colors.white,
  });
} 