import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';
import '../models/note.dart';
import '../widgets/note_editor_dialog.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Note> _filterNotes(List<Note> notes) {
    if (_searchQuery.isEmpty) return notes;
    return notes.where((note) =>
      note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      note.content.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              style: theme.textTheme.titleMedium,
              decoration: InputDecoration(
                hintText: 'Search notes...',
                hintStyle: theme.textTheme.titleMedium?.copyWith(
                  color: theme.textTheme.titleMedium?.color?.withOpacity(0.5),
                ),
                border: InputBorder.none,
              ),
            )
          : const Text('Notes'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pinned'),
            Tab(text: 'Favorites'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                }
                _isSearching = !_isSearching;
              });
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotesGrid(context, (notes) => notes),
          _buildNotesGrid(context, (notes) => notes.where((note) => note.isPinned).toList()),
          _buildNotesGrid(context, (notes) => notes.where((note) => note.isFavorite).toList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteEditor(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNotesGrid(BuildContext context, List<Note> Function(List<Note>) filter) {
    return Consumer<NotesProvider>(
      builder: (context, notesProvider, _) {
        final notes = _filterNotes(filter(notesProvider.notes));
        
        if (notes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _tabController.index == 0
                      ? Icons.note_add
                      : _tabController.index == 1
                          ? Icons.push_pin
                          : Icons.favorite,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'No notes found'
                      : _tabController.index == 0
                          ? 'No notes yet'
                          : _tabController.index == 1
                              ? 'No pinned notes'
                              : 'No favorite notes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Colors.blue.shade300,
                  width: 1.5,
                ),
              ),
              child: InkWell(
                onTap: () => _showNoteEditor(context, note),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: note.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Text(
                                note.content,
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                note.isFavorite ? Icons.favorite : Icons.favorite_border,
                                size: 20,
                                color: note.isFavorite ? Colors.red : null,
                              ),
                              onPressed: () {
                                notesProvider.toggleFavorite(note.id);
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                                size: 20,
                                color: note.isPinned ? Theme.of(context).colorScheme.primary : null,
                              ),
                              onPressed: () {
                                notesProvider.togglePin(note.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showNoteEditor(BuildContext context, [Note? note]) async {
    final result = await showDialog<Note>(
      context: context,
      builder: (context) => Hero(
        tag: note != null ? 'note_${note.id}' : 'new_note',
        child: NoteEditorDialog(note: note),
      ),
    );

    if (result != null) {
      final notesProvider = context.read<NotesProvider>();
      if (note == null) {
        notesProvider.addNote(result);
      } else {
        notesProvider.updateNote(result);
      }
    }
  }
} 