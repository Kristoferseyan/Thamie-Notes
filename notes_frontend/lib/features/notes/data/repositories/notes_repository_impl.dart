import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';
import '../datasources/notes_remote_data_source.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesRemoteDataSource remoteDataSource;

  NotesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Note>> getUserNotes() async {
    try {
      final noteModels = await remoteDataSource.getUserNotes();
      return noteModels;
    } catch (e) {
      throw Exception('Failed to get user notes: $e');
    }
  }

  @override
  Future<Note> createNote({
    required String title,
    required String content,
  }) async {
    try {
      final noteModel = await remoteDataSource.createNote(
        title: title,
        content: content,
      );
      return noteModel;
    } catch (e) {
      throw Exception('Failed to create note: $e');
    }
  }

  @override
  Future<Note> updateNote({
    required String id,
    required String title,
    required String content,
  }) async {
    try {
      final noteModel = await remoteDataSource.updateNote(
        id: id,
        title: title,
        content: content,
      );
      return noteModel;
    } catch (e) {
      throw Exception('Failed to update note: $e');
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    try {
      await remoteDataSource.deleteNote(id);
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }
}
