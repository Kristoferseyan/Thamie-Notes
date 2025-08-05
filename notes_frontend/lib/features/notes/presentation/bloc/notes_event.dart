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
  final String? folderId;

  const NotesCreateRequested({
    required this.title,
    required this.content,
    this.folderId,
  });

  @override
  List<Object> get props => [title, content, folderId ?? ''];
}

class NotesUpdateRequested extends NotesEvent {
  final String id;
  final String title;
  final String content;
  final String? folderId;

  const NotesUpdateRequested({
    required this.id,
    required this.title,
    required this.content,
    this.folderId,
  });

  @override
  List<Object> get props => [id, title, content, folderId ?? ''];
}

class NotesDeleteRequested extends NotesEvent {
  final String id;

  const NotesDeleteRequested({required this.id});

  @override
  List<Object> get props => [id];
}

class NotesRefreshRequested extends NotesEvent {}
