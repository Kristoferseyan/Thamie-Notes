import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/folder_model.dart';

abstract class FolderRemoteDataSource {
  Future<List<FolderModel>> getFolders();
  Future<FolderModel> createFolder(String title);
  Future<void> deleteFolder(String id);
}

class FolderRemoteDataSourceImpl implements FolderRemoteDataSource {
  final http.Client client;
  final SharedPreferences sharedPreferences;

  FolderRemoteDataSourceImpl({
    required this.client,
    required this.sharedPreferences,
  });

  String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://localhost:8080';

  Future<String?> get _token async {
    return sharedPreferences.getString('user_token');
  }

  Future<Map<String, String>> get _headers async {
    final token = await _token;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<FolderModel>> getFolders() async {
    final headers = await _headers;

    final response = await client.get(
      Uri.parse('$baseUrl/folder/getFolders'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final dynamic jsonResponse = json.decode(response.body);

      List<dynamic> foldersJson;
      if (jsonResponse is Map<String, dynamic>) {
        if (jsonResponse.containsKey('data')) {
          foldersJson = jsonResponse['data'] as List<dynamic>;
        } else if (jsonResponse.containsKey('folders')) {
          foldersJson = jsonResponse['folders'] as List<dynamic>;
        } else {
          foldersJson = [jsonResponse];
        }
      } else if (jsonResponse is List) {
        foldersJson = jsonResponse;
      } else {
        throw Exception('Unexpected response format');
      }

      return foldersJson
          .map(
            (folderJson) =>
                FolderModel.fromJson(folderJson as Map<String, dynamic>),
          )
          .toList();
    } else {
      throw Exception('Failed to fetch folders: ${response.body}');
    }
  }

  @override
  Future<FolderModel> createFolder(String title) async {
    final headers = await _headers;

    final response = await client.post(
      Uri.parse('$baseUrl/folder/createFolder'),
      headers: headers,
      body: json.encode({'title': title}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      return FolderModel.fromJson(jsonResponse as Map<String, dynamic>);
    } else {
      throw Exception('Failed to create folder: ${response.body}');
    }
  }

  @override
  Future<void> deleteFolder(String id) async {
    final headers = await _headers;

    final response = await client.delete(
      Uri.parse('$baseUrl/folder/deleteFolder/$id'),
      headers: headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete folder: ${response.body}');
    }
  }
}
