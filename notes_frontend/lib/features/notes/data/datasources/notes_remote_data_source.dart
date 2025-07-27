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
  });
  Future<NoteModel> updateNote({
    required String id,
    required String title,
    required String content,
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
    print(
      'NotesDataSource: Retrieved token from storage: ${token?.substring(0, 20)}...',
    );
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

      print('NotesDataSource: Parsed ${notes.length} notes successfully');
      return notes;
    } else {
      throw Exception('Failed to fetch notes: ${response.body}');
    }
  }

  @override
  Future<NoteModel> createNote({
    required String title,
    required String content,
  }) async {
    final headers = await _headers;

    final body = json.encode({'title': title, 'content': content});

    final response = await client.post(
      Uri.parse('$baseUrl/note/createNote'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      Map<String, dynamic> noteJson;
      if (jsonResponse.containsKey('data')) {
        noteJson = jsonResponse['data'] as Map<String, dynamic>;
      } else if (jsonResponse.containsKey('note')) {
        noteJson = jsonResponse['note'] as Map<String, dynamic>;
      } else {
        noteJson = jsonResponse;
      }

      return NoteModel.fromJson(noteJson);
    } else {
      throw Exception('Failed to create note: ${response.body}');
    }
  }

  @override
  Future<NoteModel> updateNote({
    required String id,
    required String title,
    required String content,
  }) async {
    final headers = await _headers;

    final body = json.encode({'title': title, 'content': content});

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

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      Map<String, dynamic> noteJson;
      if (jsonResponse.containsKey('data')) {
        noteJson = jsonResponse['data'] as Map<String, dynamic>;
        print('NotesDataSource: Found updated note in data key');
      } else if (jsonResponse.containsKey('note')) {
        noteJson = jsonResponse['note'] as Map<String, dynamic>;
        print('NotesDataSource: Found updated note in note key');
      } else {
        noteJson = jsonResponse;
        print('NotesDataSource: Using response as note object directly');
      }

      final updatedNote = NoteModel.fromJson(noteJson);
      print(
        'NotesDataSource: Successfully parsed updated note with ID: ${updatedNote.id}',
      );
      return updatedNote;
    } else {
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
      throw Exception('Failed to delete note: ${response.body}');
    }

    print('NotesDataSource: Note deleted successfully');
  }
}
