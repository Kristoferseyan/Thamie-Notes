import '../entities/note.dart';
import '../repositories/notes_repository.dart';

class CreateNoteUseCase {
  final NotesRepository repository;

  CreateNoteUseCase(this.repository);

  Future<Note> call({
    required String title,
    required String content,
    String? folderId,
  }) async {
    return await repository.createNote(
      title: title,
      content: content,
      folderId: folderId,
    );
  }
}
