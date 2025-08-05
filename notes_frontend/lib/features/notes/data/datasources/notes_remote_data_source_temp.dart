import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/note_model.dart';

abstract class NotesRemoteDataSource {
  Future<List<NoteModel>> getUserNotes();
  Future<NoteModel> createNote({
    required String title,
    required String content,
    String? folderId,
  });
  Future<NoteModel> updateNote({
    required String id,
    required String title,
    required String content,
    String? folderId,
  });
  Future<void> deleteNote(String id);
}

class NotesRemoteDataSourceImpl implements NotesRemoteDataSource {
  final http.Client client;
  final SharedPreferences sharedPreferences;

  NotesRemoteDataSourceImpl({
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
  Future<List<NoteModel>> getUserNotes() async {
    final headers = await _headers;

    print('NotesDataSource: Fetching notes from $baseUrl/note/getUserNotes');
    print('NotesDataSource: Headers: $headers');

    final response = await client.get(
      Uri.parse('$baseUrl/note/getUserNotes'),
      headers: headers,
    );

    print('NotesDataSource: Response status: ${response.statusCode}');
    print('NotesDataSource: Response body: ${response.body}');

    if (response.statusCode == 200) {
      final dynamic jsonResponse = json.decode(response.body);

      List<dynamic> notesJson;
      if (jsonResponse is Map<String, dynamic>) {
        print('NotesDataSource: Response is a Map');
        if (jsonResponse.containsKey('data')) {
          notesJson = jsonResponse['data'] as List<dynamic>;
          print(
            'NotesDataSource: Found data key with ${notesJson.length} notes',
          );
        } else if (jsonResponse.containsKey('notes')) {
          notesJson = jsonResponse['notes'] as List<dynamic>;
          print(
            'NotesDataSource: Found notes key with ${notesJson.length} notes',
          );
        } else {
          notesJson = [jsonResponse];
          print('NotesDataSource: Single note object, wrapping in array');
        }
      } else if (jsonResponse is List) {
        notesJson = jsonResponse;
        print(
          'NotesDataSource: Response is a List with ${notesJson.length} notes',
        );
      } else {
        throw Exception('Unexpected response format');
      }

      final notes = notesJson
          .map(
            (noteJson) => NoteModel.fromJson(noteJson as Map<String, dynamic>),
          )
          .toList();

      print('NotesDataSource: Successfully parsed ${notes.length} notes');
      return notes;
    } else {
      print('NotesDataSource: Error response: ${response.body}');
      throw Exception('Failed to fetch notes: ${response.body}');
    }
  }

  @override
  Future<NoteModel> createNote({
    required String title,
    required String content,
    String? folderId,
  }) async {
    final headers = await _headers;

    final body = json.encode({
      'title': title,
      'content': content,
      'folder_id':
          folderId ?? 'default', // Provide a default folder_id if none selected
    });

    print('NotesDataSource: Creating note');
    print('NotesDataSource: Create URL: $baseUrl/note/createNote');
    print('NotesDataSource: Create Body: $body');
    print('NotesDataSource: Create Headers: $headers');

    final response = await client.post(
      Uri.parse('$baseUrl/note/createNote'),
      headers: headers,
      body: body,
    );

    print('NotesDataSource: Create Response Status: ${response.statusCode}');
    print('NotesDataSource: Create Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final jsonResponse = json.decode(response.body);
        print('NotesDataSource: Parsed create response successfully');

        if (jsonResponse is Map<String, dynamic>) {
          return NoteModel.fromJson(jsonResponse);
        } else if (jsonResponse is List && jsonResponse.isNotEmpty) {
          return NoteModel.fromJson(jsonResponse.first as Map<String, dynamic>);
        } else {
          throw Exception('Invalid response format for created note');
        }
      } catch (e) {
        print('NotesDataSource: Error parsing create response: $e');
        print('NotesDataSource: Raw response: ${response.body}');
        throw Exception('Failed to parse created note: $e');
      }
    } else {
      print(
        'NotesDataSource: Create failed with status ${response.statusCode}',
      );
      throw Exception('Failed to create note: ${response.body}');
    }
  }

  @override
  Future<NoteModel> updateNote({
    required String id,
    required String title,
    required String content,
    String? folderId,
  }) async {
    final headers = await _headers;

    final body = json.encode({
      'title': title,
      'content': content,
      'folder_id':
          folderId ?? 'default', // Provide a default folder_id if none selected
    });

    print('NotesDataSource: Updating note with ID: $id');
    print('NotesDataSource: Update URL: $baseUrl/note/updateNote/$id');
    print('NotesDataSource: Update Body: $body');
    print('NotesDataSource: Update Headers: $headers');

    final response = await client.put(
      Uri.parse('$baseUrl/note/updateNote/$id'),
      headers: headers,
      body: body,
    );

    print('NotesDataSource: Update Response Status: ${response.statusCode}');
    print('NotesDataSource: Update Response Body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final jsonResponse = json.decode(response.body);
        print('NotesDataSource: Parsed update response successfully');
        return NoteModel.fromJson(jsonResponse as Map<String, dynamic>);
      } catch (e) {
        print('NotesDataSource: Error parsing update response: $e');
        throw Exception('Failed to parse updated note: $e');
      }
    } else {
      print(
        'NotesDataSource: Update failed with status ${response.statusCode}',
      );
      throw Exception('Failed to update note: ${response.body}');
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    final headers = await _headers;

    print('NotesDataSource: Deleting note with ID: $id');
    print('NotesDataSource: Delete URL: $baseUrl/note/deleteNote/$id');
    print('NotesDataSource: Delete Headers: $headers');

    final response = await client.delete(
      Uri.parse('$baseUrl/note/deleteNote/$id'),
      headers: headers,
    );

    print('NotesDataSource: Delete Response Status: ${response.statusCode}');
    print('NotesDataSource: Delete Response Body: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 204) {
      print(
        'NotesDataSource: Delete failed with status ${response.statusCode}',
      );
      throw Exception('Failed to delete note: ${response.body}');
    }
  }
}
