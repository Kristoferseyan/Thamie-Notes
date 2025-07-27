import '../repositories/auth_repository.dart';

class GetStoredTokenUseCase {
  final AuthRepository repository;

  GetStoredTokenUseCase(this.repository);

  Future<String?> call() async {
    return await repository.getStoredToken();
  }
}
