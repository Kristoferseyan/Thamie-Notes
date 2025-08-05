import '../entities/note.dart';

abstract class NotesRepository {
  Future<List<Note>> getUserNotes();
  Future<Note> createNote({
    required String title,
    required String content,
    String? folderId,
  });
  Future<Note> updateNote({
    required String id,
    required String title,
    required String content,
    String? folderId,
  });
  Future<void> deleteNote(String id);
}
