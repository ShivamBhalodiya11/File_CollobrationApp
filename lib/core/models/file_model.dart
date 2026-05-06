import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'file_model.g.dart';

@HiveType(typeId: 0)
class FileVersion extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int versionNumber;

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final String authorId;

  @HiveField(4)
  final String authorEmail;

  @HiveField(5)
  final String changeNote;

  FileVersion({
    String? id,
    required this.versionNumber,
    required this.timestamp,
    required this.authorId,
    required this.authorEmail,
    this.changeNote = 'Initial version',
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() => {
        'id': id,
        'versionNumber': versionNumber,
        'timestamp': timestamp.toIso8601String(),
        'authorId': authorId,
        'authorEmail': authorEmail,
        'changeNote': changeNote,
      };

  factory FileVersion.fromMap(Map<String, dynamic> map) => FileVersion(
        id: map['id'],
        versionNumber: map['versionNumber'],
        timestamp: DateTime.parse(map['timestamp']),
        authorId: map['authorId'],
        authorEmail: map['authorEmail'],
        changeNote: map['changeNote'] ?? '',
      );
}

@HiveType(typeId: 1)
class FileComment extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final String authorId;

  @HiveField(4)
  final String authorEmail;

  FileComment({
    String? id,
    required this.text,
    required this.timestamp,
    required this.authorId,
    required this.authorEmail,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() => {
        'id': id,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
        'authorId': authorId,
        'authorEmail': authorEmail,
      };

  factory FileComment.fromMap(Map<String, dynamic> map) => FileComment(
        id: map['id'],
        text: map['text'],
        timestamp: DateTime.parse(map['timestamp']),
        authorId: map['authorId'],
        authorEmail: map['authorEmail'],
      );
}

@HiveType(typeId: 2)
enum FileType {
  @HiveField(0)
  document,
  @HiveField(1)
  image,
  @HiveField(2)
  video,
  @HiveField(3)
  audio,
  @HiveField(4)
  spreadsheet,
  @HiveField(5)
  presentation,
  @HiveField(6)
  pdf,
  @HiveField(7)
  archive,
  @HiveField(8)
  other,
}

extension FileTypeExtension on FileType {
  String get label {
    switch (this) {
      case FileType.document:
        return 'Document';
      case FileType.image:
        return 'Image';
      case FileType.video:
        return 'Video';
      case FileType.audio:
        return 'Audio';
      case FileType.spreadsheet:
        return 'Spreadsheet';
      case FileType.presentation:
        return 'Presentation';
      case FileType.pdf:
        return 'PDF';
      case FileType.archive:
        return 'Archive';
      case FileType.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case FileType.document:
        return '📄';
      case FileType.image:
        return '🖼️';
      case FileType.video:
        return '🎬';
      case FileType.audio:
        return '🎵';
      case FileType.spreadsheet:
        return '📊';
      case FileType.presentation:
        return '📑';
      case FileType.pdf:
        return '📕';
      case FileType.archive:
        return '🗜️';
      case FileType.other:
        return '📁';
    }
  }
}

@HiveType(typeId: 3)
class ConflictInfo extends HiveObject {
  @HiveField(0)
  final String conflictingVersionId;

  @HiveField(1)
  final DateTime conflictTimestamp;

  @HiveField(2)
  final String resolution; // 'latest_wins' | 'keep_both' | 'manual'

  @HiveField(3)
  bool resolved;

  ConflictInfo({
    required this.conflictingVersionId,
    required this.conflictTimestamp,
    this.resolution = 'keep_both',
    this.resolved = false,
  });
}

@HiveType(typeId: 4)
class FileModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  FileType type;

  @HiveField(3)
  String description;

  @HiveField(4)
  final String ownerId;

  @HiveField(5)
  final String ownerEmail;

  @HiveField(6)
  bool isShared;

  @HiveField(7)
  List<String> sharedWith; // list of user emails

  @HiveField(8)
  List<FileVersion> versions;

  @HiveField(9)
  List<FileComment> comments;

  @HiveField(10)
  DateTime createdAt;

  @HiveField(11)
  DateTime updatedAt;

  @HiveField(12)
  bool isSynced;

  @HiveField(13)
  bool hasPendingChanges;

  @HiveField(14)
  List<ConflictInfo> conflicts;

  @HiveField(15)
  int fileSizeKb;

  @HiveField(16)
  String? thumbnailPath;

  FileModel({
    String? id,
    required this.name,
    required this.type,
    required this.description,
    required this.ownerId,
    required this.ownerEmail,
    this.isShared = false,
    List<String>? sharedWith,
    List<FileVersion>? versions,
    List<FileComment>? comments,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isSynced = false,
    this.hasPendingChanges = true,
    List<ConflictInfo>? conflicts,
    this.fileSizeKb = 0,
    this.thumbnailPath,
  })  : id = id ?? const Uuid().v4(),
        sharedWith = sharedWith ?? [],
        versions = versions ?? [],
        comments = comments ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        conflicts = conflicts ?? [];

  int get currentVersionNumber =>
      versions.isEmpty ? 0 : versions.last.versionNumber;

  bool get hasConflicts => conflicts.any((c) => !c.resolved);

  Map<String, dynamic> toFirestoreMap() => {
        'id': id,
        'name': name,
        'type': type.index,
        'description': description,
        'ownerId': ownerId,
        'ownerEmail': ownerEmail,
        'isShared': isShared,
        'sharedWith': sharedWith,
        'versions': versions.map((v) => v.toMap()).toList(),
        'comments': comments.map((c) => c.toMap()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'isSynced': isSynced,
        'hasPendingChanges': hasPendingChanges,
        'fileSizeKb': fileSizeKb,
      };
}
