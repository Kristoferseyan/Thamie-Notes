import '../entities/folder.dart';
import '../repositories/folder_repository.dart';

class CreateFolder {
  final FolderRepository repository;

  CreateFolder(this.repository);

  Future<Folder> call(String title) async {
    return await repository.createFolder(title);
  }
}
