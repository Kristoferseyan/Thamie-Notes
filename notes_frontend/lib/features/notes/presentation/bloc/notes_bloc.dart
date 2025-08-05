import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_user_notes_usecase.dart';
import '../../domain/usecases/create_note_usecase.dart';
import '../../domain/usecases/update_note_usecase.dart';
import '../../domain/usecases/delete_note_usecase.dart';
import 'notes_event.dart';
import 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final GetUserNotesUseCase getUserNotesUseCase;
  final CreateNoteUseCase createNoteUseCase;
  final UpdateNoteUseCase updateNoteUseCase;
  final DeleteNoteUseCase deleteNoteUseCase;

  NotesBloc({
    required this.getUserNotesUseCase,
    required this.createNoteUseCase,
    required this.updateNoteUseCase,
    required this.deleteNoteUseCase,
  }) : super(const NotesState()) {
    on<NotesLoadRequested>(_onNotesLoadRequested);
    on<NotesCreateRequested>(_onNotesCreateRequested);
    on<NotesUpdateRequested>(_onNotesUpdateRequested);
    on<NotesDeleteRequested>(_onNotesDeleteRequested);
    on<NotesRefreshRequested>(_onNotesRefreshRequested);
  }

  Future<void> _onNotesLoadRequested(
    NotesLoadRequested event,
    Emitter<NotesState> emit,
  ) async {
    print('NotesBloc: Loading notes requested');
    emit(state.copyWith(status: NotesStatus.loading));

    try {
      print('NotesBloc: Calling getUserNotesUseCase...');
      final notes = await getUserNotesUseCase();
      print('NotesBloc: Got ${notes.length} notes from use case');
      for (int i = 0; i < notes.length; i++) {
        print('NotesBloc: Note $i: ${notes[i].title}');
      }
      emit(state.copyWith(status: NotesStatus.loaded, notes: notes));
      print('NotesBloc: State updated with loaded notes');
    } catch (e) {
      print('NotesBloc: Error loading notes: $e');
      emit(state.copyWith(status: NotesStatus.error, message: e.toString()));
    }
  }

  Future<void> _onNotesCreateRequested(
    NotesCreateRequested event,
    Emitter<NotesState> emit,
  ) async {
    print('NotesBloc: Creating note requested');
    emit(state.copyWith(status: NotesStatus.creating));

    try {
      print('NotesBloc: Calling createNoteUseCase...');
      final newNote = await createNoteUseCase(
        title: event.title,
        content: event.content,
        folderId: event.folderId,
      );
      print('NotesBloc: Note created successfully: ${newNote.id}');

      print('NotesBloc: Refreshing notes list after creation...');
      final refreshedNotes = await getUserNotesUseCase();
      print('NotesBloc: Got ${refreshedNotes.length} notes after refresh');

      emit(
        state.copyWith(
          status: NotesStatus.created,
          notes: refreshedNotes,
          message: 'Note created successfully',
        ),
      );
      print('NotesBloc: State updated with refreshed notes list');
    } catch (e) {
      print('NotesBloc: Error creating note: $e');
      emit(state.copyWith(status: NotesStatus.error, message: e.toString()));
    }
  }

  Future<void> _onNotesRefreshRequested(
    NotesRefreshRequested event,
    Emitter<NotesState> emit,
  ) async {
    try {
      final notes = await getUserNotesUseCase();
      emit(state.copyWith(status: NotesStatus.loaded, notes: notes));
    } catch (e) {
      emit(state.copyWith(status: NotesStatus.error, message: e.toString()));
    }
  }

  Future<void> _onNotesUpdateRequested(
    NotesUpdateRequested event,
    Emitter<NotesState> emit,
  ) async {
    print('NotesBloc: Updating note ${event.id}...');
    emit(state.copyWith(status: NotesStatus.updating));

    try {
      final updatedNote = await updateNoteUseCase(
        id: event.id,
        title: event.title,
        content: event.content,
        folderId: event.folderId,
      );
      print('NotesBloc: Note updated successfully: ${updatedNote.id}');

      print('NotesBloc: Refreshing notes list after update...');
      final refreshedNotes = await getUserNotesUseCase();
      print('NotesBloc: Got ${refreshedNotes.length} notes after refresh');

      emit(
        state.copyWith(
          status: NotesStatus.updated,
          notes: refreshedNotes,
          message: 'Note updated successfully',
        ),
      );
      print('NotesBloc: State updated with refreshed notes list');
    } catch (e) {
      print('NotesBloc: Error updating note: $e');
      emit(state.copyWith(status: NotesStatus.error, message: e.toString()));
    }
  }

  Future<void> _onNotesDeleteRequested(
    NotesDeleteRequested event,
    Emitter<NotesState> emit,
  ) async {
    print('NotesBloc: Deleting note ${event.id}...');
    emit(state.copyWith(status: NotesStatus.deleting));

    try {
      await deleteNoteUseCase(event.id);
      print('NotesBloc: Note deleted successfully');

      print('NotesBloc: Refreshing notes list after deletion...');
      final refreshedNotes = await getUserNotesUseCase();
      print('NotesBloc: Got ${refreshedNotes.length} notes after refresh');

      emit(
        state.copyWith(
          status: NotesStatus.deleted,
          notes: refreshedNotes,
          message: 'Note deleted successfully',
        ),
      );
      print('NotesBloc: State updated with refreshed notes list');
    } catch (e) {
      print('NotesBloc: Error deleting note: $e');
      emit(state.copyWith(status: NotesStatus.error, message: e.toString()));
    }
  }
}
