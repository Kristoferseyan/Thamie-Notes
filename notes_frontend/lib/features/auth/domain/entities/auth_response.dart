import 'package:equatable/equatable.dart';
import 'user.dart';

class AuthResponse extends Equatable {
  final String token;
  final User? user;
  final String? message;

  const AuthResponse({required this.token, this.user, this.message});

  @override
  List<Object?> get props => [token, user, message];
}
