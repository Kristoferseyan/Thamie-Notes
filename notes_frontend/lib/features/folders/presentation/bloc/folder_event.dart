import 'package:equatable/equatable.dart';

abstract class FolderEvent extends Equatable {
  const FolderEvent();

  @override
  List<Object?> get props => [];
}

class FoldersLoadRequested extends FolderEvent {}

class FolderCreateRequested extends FolderEvent {
  final String title;

  const FolderCreateRequested({required this.title});

  @override
  List<Object?> get props => [title];
}

class FolderDeleteRequested extends FolderEvent {
  final String id;

  const FolderDeleteRequested({required this.id});

  @override
  List<Object?> get props => [id];
}
