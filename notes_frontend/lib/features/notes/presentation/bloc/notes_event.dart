import 'package:equatable/equatable.dart';

abstract class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object> get props => [];
}

class NotesLoadRequested extends NotesEvent {}

class NotesCreateRequested extends NotesEvent {
  final String title;
  final String content;

  const NotesCreateRequested({required this.title, required this.content});

  @override
  List<Object> get props => [title, content];
}

class NotesUpdateRequested extends NotesEvent {
  final String id;
  final String title;
  final String content;

  const NotesUpdateRequested({
    required this.id,
    required this.title,
    required this.content,
  });

  @override
  List<Object> get props => [id, title, content];
}

class NotesDeleteRequested extends NotesEvent {
  final String id;

  const NotesDeleteRequested({required this.id});

  @override
  List<Object> get props => [id];
}

class NotesRefreshRequested extends NotesEvent {}
