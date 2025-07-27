import '../repositories/auth_repository.dart';

class CreateUserUseCase {
  final AuthRepository repository;

  CreateUserUseCase(this.repository);

  Future<void> call({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
  }) async {
    return await repository.createUser(
      firstName: firstName,
      lastName: lastName,
      username: username,
      email: email,
      password: password,
    );
  }
}
