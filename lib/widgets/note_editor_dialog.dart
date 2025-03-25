import 'package:flutter/material.dart';
import '../models/note.dart';

class NoteEditorDialog extends StatefulWidget {
  final Note? note;

  const NoteEditorDialog({super.key, this.note});

  @override
  State<NoteEditorDialog> createState() => _NoteEditorDialogState();
}

class _NoteEditorDialogState extends State<NoteEditorDialog> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _selectedColor = widget.note?.color ?? Colors.white;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.note == null ? 'Add Note' : 'Edit Note'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.blue.shade300
                        : Theme.of(context).colorScheme.outline,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.blue.shade300
                        : Theme.of(context).colorScheme.outline,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.blue.shade300
                        : Theme.of(context).colorScheme.outline,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.blue.shade300
                        : Theme.of(context).colorScheme.outline,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                Colors.white,
                Colors.red.shade100,
                Colors.pink.shade100,
                Colors.purple.shade100,
                Colors.blue.shade100,
                Colors.teal.shade100,
                Colors.green.shade100,
                Colors.orange.shade100,
                Colors.amber.shade100,
                Colors.brown.shade100,
              ].map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColor == color
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final note = Note(
              id: widget.note?.id ?? DateTime.now().toString(),
              title: _titleController.text,
              content: _contentController.text,
              createdAt: widget.note?.createdAt ?? DateTime.now(),
              isPinned: widget.note?.isPinned ?? false,
              isFavorite: widget.note?.isFavorite ?? false,
              color: _selectedColor,
            );
            Navigator.pop(context, note);
          },
          child: Text(widget.note == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
} 