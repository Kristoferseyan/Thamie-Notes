import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/create_user_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/get_stored_token_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

import 'features/notes/data/datasources/notes_remote_data_source.dart';
import 'features/notes/data/repositories/notes_repository_impl.dart';
import 'features/notes/domain/repositories/notes_repository.dart';
import 'features/notes/domain/usecases/get_user_notes_usecase.dart';
import 'features/notes/domain/usecases/create_note_usecase.dart';
import 'features/notes/domain/usecases/update_note_usecase.dart';
import 'features/notes/domain/usecases/delete_note_usecase.dart';
import 'features/notes/presentation/bloc/notes_bloc.dart';

import 'features/folders/data/datasources/folder_remote_data_source.dart';
import 'features/folders/data/repositories/folder_repository_impl.dart';
import 'features/folders/domain/repositories/folder_repository.dart';
import 'features/folders/domain/usecases/get_folders.dart';
import 'features/folders/domain/usecases/create_folder.dart';
import 'features/folders/domain/usecases/delete_folder.dart';
import 'features/folders/presentation/bloc/folder_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<NotesRemoteDataSource>(
    () => NotesRemoteDataSourceImpl(client: sl(), sharedPreferences: sl()),
  );
  sl.registerLazySingleton<FolderRemoteDataSource>(
    () => FolderRemoteDataSourceImpl(client: sl(), sharedPreferences: sl()),
  ); // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), sharedPreferences: sl()),
  );
  sl.registerLazySingleton<NotesRepository>(
    () => NotesRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<FolderRepository>(
    () => FolderRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => CreateUserUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetStoredTokenUseCase(sl()));
  sl.registerLazySingleton(() => GetUserNotesUseCase(sl()));
  sl.registerLazySingleton(() => CreateNoteUseCase(sl()));
  sl.registerLazySingleton(() => UpdateNoteUseCase(sl()));
  sl.registerLazySingleton(() => DeleteNoteUseCase(sl()));
  sl.registerLazySingleton(() => GetFolders(sl()));
  sl.registerLazySingleton(() => CreateFolder(sl()));
  sl.registerLazySingleton(() => DeleteFolder(sl()));

  // BLoC
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      createUserUseCase: sl(),
      logoutUseCase: sl(),
      getStoredTokenUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => NotesBloc(
      getUserNotesUseCase: sl(),
      createNoteUseCase: sl(),
      updateNoteUseCase: sl(),
      deleteNoteUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => FolderBloc(getFolders: sl(), createFolder: sl(), deleteFolder: sl()),
  );
}
