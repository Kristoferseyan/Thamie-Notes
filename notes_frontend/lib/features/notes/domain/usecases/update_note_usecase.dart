import '../entities/note.dart';
import '../repositories/notes_repository.dart';

class UpdateNoteUseCase {
  final NotesRepository repository;

  UpdateNoteUseCase(this.repository);

  Future<Note> call({
    required String id,
    required String title,
    required String content,
  }) async {
    return await repository.updateNote(id: id, title: title, content: content);
  }
}
