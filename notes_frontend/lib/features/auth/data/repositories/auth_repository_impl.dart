import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/auth_response.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SharedPreferences sharedPreferences;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.sharedPreferences,
  });

  @override
  Future<AuthResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.login(
        username: username,
        password: password,
      );

      await storeToken(result.token);

      return AuthResponse(
        token: result.token,
        user: result.user?.toEntity(),
        message: result.message,
      );
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<void> createUser({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      await remoteDataSource.createUser(
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('User creation failed: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    await sharedPreferences.remove('user_token');
    await sharedPreferences.remove('user_data');
  }

  @override
  Future<String?> getStoredToken() async {
    return sharedPreferences.getString('user_token');
  }

  @override
  Future<void> storeToken(String token) async {
    await sharedPreferences.setString('user_token', token);
  }
}
