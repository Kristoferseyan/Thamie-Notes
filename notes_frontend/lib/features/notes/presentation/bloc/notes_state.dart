import 'package:equatable/equatable.dart';
import '../../domain/entities/note.dart';

enum NotesStatus {
  initial,
  loading,
  loaded,
  error,
  creating,
  created,
  updating,
  updated,
  deleting,
  deleted,
}

class NotesState extends Equatable {
  final NotesStatus status;
  final List<Note> notes;
  final String? message;

  const NotesState({
    this.status = NotesStatus.initial,
    this.notes = const [],
    this.message,
  });

  NotesState copyWith({
    NotesStatus? status,
    List<Note>? notes,
    String? message,
  }) {
    return NotesState(
      status: status ?? this.status,
      notes: notes ?? this.notes,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, notes, message];
}
