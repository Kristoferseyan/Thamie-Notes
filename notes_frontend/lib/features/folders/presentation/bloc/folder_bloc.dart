import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_folders.dart';
import '../../domain/usecases/create_folder.dart';
import '../../domain/usecases/delete_folder.dart';
import 'folder_event.dart';
import 'folder_state.dart';

class FolderBloc extends Bloc<FolderEvent, FolderState> {
  final GetFolders _getFolders;
  final CreateFolder _createFolder;
  final DeleteFolder _deleteFolder;

  FolderBloc({
    required GetFolders getFolders,
    required CreateFolder createFolder,
    required DeleteFolder deleteFolder,
  }) : _getFolders = getFolders,
       _createFolder = createFolder,
       _deleteFolder = deleteFolder,
       super(const FolderState()) {
    on<FoldersLoadRequested>(_onFoldersLoadRequested);
    on<FolderCreateRequested>(_onFolderCreateRequested);
    on<FolderDeleteRequested>(_onFolderDeleteRequested);
  }

  Future<void> _onFoldersLoadRequested(
    FoldersLoadRequested event,
    Emitter<FolderState> emit,
  ) async {
    emit(state.copyWith(status: FolderStatus.loading));

    try {
      final folders = await _getFolders();
      emit(state.copyWith(status: FolderStatus.loaded, folders: folders));
    } catch (e) {
      emit(state.copyWith(status: FolderStatus.error, message: e.toString()));
    }
  }

  Future<void> _onFolderCreateRequested(
    FolderCreateRequested event,
    Emitter<FolderState> emit,
  ) async {
    emit(state.copyWith(status: FolderStatus.loading));

    try {
      final newFolder = await _createFolder(event.title);
      final updatedFolders = [...state.folders, newFolder];

      emit(
        state.copyWith(status: FolderStatus.created, folders: updatedFolders),
      );
    } catch (e) {
      emit(state.copyWith(status: FolderStatus.error, message: e.toString()));
    }
  }

  Future<void> _onFolderDeleteRequested(
    FolderDeleteRequested event,
    Emitter<FolderState> emit,
  ) async {
    emit(state.copyWith(status: FolderStatus.loading));

    try {
      await _deleteFolder(event.id);
      final updatedFolders = state.folders
          .where((folder) => folder.id != event.id)
          .toList();

      emit(
        state.copyWith(status: FolderStatus.deleted, folders: updatedFolders),
      );
    } catch (e) {
      emit(state.copyWith(status: FolderStatus.error, message: e.toString()));
    }
  }
}
