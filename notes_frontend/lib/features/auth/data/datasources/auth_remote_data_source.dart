import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
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
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSourceImpl({required this.client});

  String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://localhost:8080';
  String get loginEndpoint => dotenv.env['LOGIN_ENDPOINT'] ?? '/auth/login';
  String get createUserEndpoint =>
      dotenv.env['CREATE_USER_ENDPOINT'] ?? '/user/addUser';

  Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  @override
  Future<AuthResponseModel> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl$loginEndpoint');
    final body = json.encode({'username': username, 'password': password});

    print('Login URL: $url');
    print('Login Body: $body');

    final response = await client.post(
      url,
      headers: defaultHeaders,
      body: body,
    );

    print('Login Response Status: ${response.statusCode}');
    print('Login Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return AuthResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to login: ${response.body}');
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
    final url = Uri.parse('$baseUrl$createUserEndpoint');
    final body = json.encode({
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'password': password,
      'email': email,
      'role': 'USER',
    });

    final response = await client.post(
      url,
      headers: defaultHeaders,
      body: body,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create user: ${response.body}');
    }
  }
}
