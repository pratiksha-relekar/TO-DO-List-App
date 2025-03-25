import 'package:flutter/material.dart';
import '../models/note.dart';

class NotesProvider with ChangeNotifier {
  final List<Note> _notes = [];

  List<Note> get notes => _notes;
  List<Note> get pinnedNotes => _notes.where((note) => note.isPinned).toList();
  List<Note> get favoriteNotes => _notes.where((note) => note.isFavorite).toList();

  void addNote(Note note) {
    _notes.add(note);
    notifyListeners();
  }

  void updateNote(Note note) {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
      notifyListeners();
    }
  }

  void deleteNote(String id) {
    _notes.removeWhere((note) => note.id == id);
    notifyListeners();
  }

  void togglePin(String id) {
    final note = _notes.firstWhere((n) => n.id == id);
    note.isPinned = !note.isPinned;
    notifyListeners();
  }

  void toggleFavorite(String id) {
    final note = _notes.firstWhere((n) => n.id == id);
    note.isFavorite = !note.isFavorite;
    notifyListeners();
  }

  void updateNoteColor(String id, Color color) {
    final note = _notes.firstWhere((n) => n.id == id);
    note.color = color;
    notifyListeners();
  }
} 