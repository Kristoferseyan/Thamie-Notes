import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

class UserModel extends Equatable {
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? role;

  const UserModel({
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] ?? json['firstName'],
      lastName: json['last_name'] ?? json['lastName'],
      role: json['role'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
    };
  }

  User toEntity() {
    return User(
      username: username,
      email: email,
      firstName: firstName,
      lastName: lastName,
      role: role,
    );
  }

  @override
  List<Object?> get props => [username, email, firstName, lastName, role];
}
