// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FileVersionAdapter extends TypeAdapter<FileVersion> {
  @override
  final int typeId = 0;

  @override
  FileVersion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FileVersion(
      id: fields[0] as String?,
      versionNumber: fields[1] as int,
      timestamp: fields[2] as DateTime,
      authorId: fields[3] as String,
      authorEmail: fields[4] as String,
      changeNote: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FileVersion obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.versionNumber)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.authorId)
      ..writeByte(4)
      ..write(obj.authorEmail)
      ..writeByte(5)
      ..write(obj.changeNote);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileVersionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

class FileCommentAdapter extends TypeAdapter<FileComment> {
  @override
  final int typeId = 1;

  @override
  FileComment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FileComment(
      id: fields[0] as String?,
      text: fields[1] as String,
      timestamp: fields[2] as DateTime,
      authorId: fields[3] as String,
      authorEmail: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FileComment obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.authorId)
      ..writeByte(4)
      ..write(obj.authorEmail);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileCommentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

class FileTypeAdapter extends TypeAdapter<FileType> {
  @override
  final int typeId = 2;

  @override
  FileType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FileType.document;
      case 1:
        return FileType.image;
      case 2:
        return FileType.video;
      case 3:
        return FileType.audio;
      case 4:
        return FileType.spreadsheet;
      case 5:
        return FileType.presentation;
      case 6:
        return FileType.pdf;
      case 7:
        return FileType.archive;
      case 8:
        return FileType.other;
      default:
        return FileType.other;
    }
  }

  @override
  void write(BinaryWriter writer, FileType obj) {
    switch (obj) {
      case FileType.document:
        writer.writeByte(0);
        break;
      case FileType.image:
        writer.writeByte(1);
        break;
      case FileType.video:
        writer.writeByte(2);
        break;
      case FileType.audio:
        writer.writeByte(3);
        break;
      case FileType.spreadsheet:
        writer.writeByte(4);
        break;
      case FileType.presentation:
        writer.writeByte(5);
        break;
      case FileType.pdf:
        writer.writeByte(6);
        break;
      case FileType.archive:
        writer.writeByte(7);
        break;
      case FileType.other:
        writer.writeByte(8);
        break;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

class ConflictInfoAdapter extends TypeAdapter<ConflictInfo> {
  @override
  final int typeId = 3;

  @override
  ConflictInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConflictInfo(
      conflictingVersionId: fields[0] as String,
      conflictTimestamp: fields[1] as DateTime,
      resolution: fields[2] as String,
      resolved: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ConflictInfo obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.conflictingVersionId)
      ..writeByte(1)
      ..write(obj.conflictTimestamp)
      ..writeByte(2)
      ..write(obj.resolution)
      ..writeByte(3)
      ..write(obj.resolved);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConflictInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

class FileModelAdapter extends TypeAdapter<FileModel> {
  @override
  final int typeId = 4;

  @override
  FileModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FileModel(
      id: fields[0] as String?,
      name: fields[1] as String,
      type: fields[2] as FileType,
      description: fields[3] as String,
      ownerId: fields[4] as String,
      ownerEmail: fields[5] as String,
      isShared: fields[6] as bool,
      sharedWith: (fields[7] as List).cast<String>(),
      versions: (fields[8] as List).cast<FileVersion>(),
      comments: (fields[9] as List).cast<FileComment>(),
      createdAt: fields[10] as DateTime,
      updatedAt: fields[11] as DateTime,
      isSynced: fields[12] as bool,
      hasPendingChanges: fields[13] as bool,
      conflicts: (fields[14] as List).cast<ConflictInfo>(),
      fileSizeKb: fields[15] as int,
      thumbnailPath: fields[16] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FileModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.ownerId)
      ..writeByte(5)
      ..write(obj.ownerEmail)
      ..writeByte(6)
      ..write(obj.isShared)
      ..writeByte(7)
      ..write(obj.sharedWith)
      ..writeByte(8)
      ..write(obj.versions)
      ..writeByte(9)
      ..write(obj.comments)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt)
      ..writeByte(12)
      ..write(obj.isSynced)
      ..writeByte(13)
      ..write(obj.hasPendingChanges)
      ..writeByte(14)
      ..write(obj.conflicts)
      ..writeByte(15)
      ..write(obj.fileSizeKb)
      ..writeByte(16)
      ..write(obj.thumbnailPath);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
