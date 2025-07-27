import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String username;
  final String password;

  const AuthLoginRequested({required this.username, required this.password});

  @override
  List<Object> get props => [username, password];
}

class AuthCreateUserRequested extends AuthEvent {
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String password;

  const AuthCreateUserRequested({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [firstName, lastName, username, email, password];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}
