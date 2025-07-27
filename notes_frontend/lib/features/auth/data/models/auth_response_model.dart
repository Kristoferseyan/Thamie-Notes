import 'package:equatable/equatable.dart';
import 'user_model.dart';

class AuthResponseModel extends Equatable {
  final String token;
  final UserModel? user;
  final String? message;

  const AuthResponseModel({required this.token, this.user, this.message});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] ?? '',
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'token': token, 'user': user?.toJson(), 'message': message};
  }

  @override
  List<Object?> get props => [token, user, message];
}
