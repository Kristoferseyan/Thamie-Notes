import '../entities/folder.dart';

abstract class FolderRepository {
  Future<List<Folder>> getFolders();
  Future<Folder> createFolder(String title);
  Future<void> deleteFolder(String id);
}
