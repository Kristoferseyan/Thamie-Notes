import '../../domain/entities/folder.dart';

class FolderModel extends Folder {
  const FolderModel({
    super.id,
    required super.title,
    super.createdAt,
    super.updatedAt,
  });

  factory FolderModel.fromJson(Map<String, dynamic> json) {
    return FolderModel(
      id: json['id'] as String?,
      title: json['title'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : (json['created_at'] != null
                ? DateTime.parse(json['created_at'] as String)
                : null),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : (json['updated_at'] != null
                ? DateTime.parse(json['updated_at'] as String)
                : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory FolderModel.fromEntity(Folder folder) {
    return FolderModel(
      id: folder.id,
      title: folder.title,
      createdAt: folder.createdAt,
      updatedAt: folder.updatedAt,
    );
  }
}
