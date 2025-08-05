import '../../domain/entities/folder.dart';
import '../../domain/repositories/folder_repository.dart';
import '../datasources/folder_remote_data_source.dart';

class FolderRepositoryImpl implements FolderRepository {
  final FolderRemoteDataSource remoteDataSource;

  FolderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Folder>> getFolders() async {
    return await remoteDataSource.getFolders();
  }

  @override
  Future<Folder> createFolder(String title) async {
    return await remoteDataSource.createFolder(title);
  }

  @override
  Future<void> deleteFolder(String id) async {
    return await remoteDataSource.deleteFolder(id);
  }
}
