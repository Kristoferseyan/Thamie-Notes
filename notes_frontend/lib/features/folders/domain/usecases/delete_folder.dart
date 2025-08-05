import '../repositories/folder_repository.dart';

class DeleteFolder {
  final FolderRepository repository;

  DeleteFolder(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteFolder(id);
  }
}
