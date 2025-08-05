import 'package:equatable/equatable.dart';

class Folder extends Equatable {
  final String? id;
  final String title;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Folder({this.id, required this.title, this.createdAt, this.updatedAt});

  Folder copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Folder(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, title, createdAt, updatedAt];
}
