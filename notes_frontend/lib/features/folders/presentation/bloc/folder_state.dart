import 'package:equatable/equatable.dart';
import '../../domain/entities/folder.dart';

enum FolderStatus { initial, loading, loaded, created, deleted, error }

class FolderState extends Equatable {
  final FolderStatus status;
  final List<Folder> folders;
  final String? message;

  const FolderState({
    this.status = FolderStatus.initial,
    this.folders = const [],
    this.message,
  });

  FolderState copyWith({
    FolderStatus? status,
    List<Folder>? folders,
    String? message,
  }) {
    return FolderState(
      status: status ?? this.status,
      folders: folders ?? this.folders,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, folders, message];
}
