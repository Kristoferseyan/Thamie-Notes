import '../entities/note.dart';
import '../repositories/notes_repository.dart';

class GetUserNotesUseCase {
  final NotesRepository repository;

  GetUserNotesUseCase(this.repository);

  Future<List<Note>> call() async {
    return await repository.getUserNotes();
  }
}
