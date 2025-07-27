import '../entities/auth_response.dart';

abstract class AuthRepository {
  Future<AuthResponse> login({
    required String username,
    required String password,
  });
  Future<void> createUser({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
  });
  Future<void> logout();
  Future<String?> getStoredToken();
  Future<void> storeToken(String token);
}
