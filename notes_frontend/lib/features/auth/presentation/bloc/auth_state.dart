import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? token;
  final String? message;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.token,
    this.message,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? token,
    String? message,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      token: token ?? this.token,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, user, token, message];
}
