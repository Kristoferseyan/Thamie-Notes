import 'package:equatable/equatable.dart';
import 'user_model.dart';

class AuthResponseModel extends Equatable {
  final String token;
  final UserModel? user;
  final String? message;

  const AuthResponseModel({required this.token, this.user, this.message});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    String actualToken = json['username'] ?? '';
    String actualUsername = json['email'] ?? '';
    String actualEmail = json['role'] ?? '';
    String actualRole = json['token'] ?? '';

    UserModel? user = UserModel(
      username: actualUsername,
      email: actualEmail,
      firstName: json['firstName'],
      lastName: json['lastName'],
      role: actualRole,
    );

    return AuthResponseModel(
      token: actualToken,
      user: user,
      message: json['message'],
    );
  }
  Map<String, dynamic> toJson() {
    return {'token': token, 'user': user?.toJson(), 'message': message};
  }

  @override
  List<Object?> get props => [token, user, message];
}
