import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/file_model.dart';
import '../services/hive_service.dart';

class FileRepository {
  Box<FileModel> get _box => HiveService.filesBox;

  // Create
  Future<void> addFile(FileModel file) async {
    await _box.put(file.id, file);
  }

  // Read all
  List<FileModel> getAllFiles() {
    return _box.values.toList();
  }

  // Read by user
  List<FileModel> getFilesByUser(String userId) {
    return _box.values
        .where((f) => f.ownerId == userId)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  // Read shared files (shared with anyone, by anyone, accessible to this user)
  List<FileModel> getSharedFiles(String userId) {
    return _box.values
        .where((f) => f.isShared && f.ownerId == userId)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  // Read received files (shared by others, where this user's email is in sharedWith)
  List<FileModel> getReceivedFiles(String userEmail) {
    return _box.values
        .where((f) => f.isShared && f.sharedWith.contains(userEmail))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  // Read by id
  FileModel? getFileById(String id) {
    return _box.get(id);
  }

  // Update
  Future<void> updateFile(FileModel file) async {
    file.updatedAt = DateTime.now();
    file.hasPendingChanges = true;
    await _box.put(file.id, file);
  }

  // Add version
  Future<void> addVersion(String fileId, FileVersion version) async {
    final file = _box.get(fileId);
    if (file != null) {
      file.versions.add(version);
      file.updatedAt = DateTime.now();
      file.hasPendingChanges = true;
      await _box.put(fileId, file);
    }
  }

  // Add comment
  Future<void> addComment(String fileId, FileComment comment) async {
    final file = _box.get(fileId);
    if (file != null) {
      file.comments.add(comment);
      file.updatedAt = DateTime.now();
      file.hasPendingChanges = true;
      await _box.put(fileId, file);
    }
  }

  // Delete comment
  Future<void> deleteComment(String fileId, String commentId) async {
    final file = _box.get(fileId);
    if (file != null) {
      file.comments.removeWhere((c) => c.id == commentId);
      file.updatedAt = DateTime.now();
      await _box.put(fileId, file);
    }
  }

  // Share file
  Future<void> shareFile(String fileId, List<String> emails) async {
    final file = _box.get(fileId);
    if (file != null) {
      file.isShared = true;
      for (final email in emails) {
        if (!file.sharedWith.contains(email)) {
          file.sharedWith.add(email);
        }
      }
      file.updatedAt = DateTime.now();
      file.hasPendingChanges = true;
      await _box.put(fileId, file);
    }
  }

  // Unshare file
  Future<void> unshareFile(String fileId) async {
    final file = _box.get(fileId);
    if (file != null) {
      file.isShared = false;
      file.sharedWith.clear();
      file.updatedAt = DateTime.now();
      file.hasPendingChanges = true;
      await _box.put(fileId, file);
    }
  }

  // Delete file
  Future<void> deleteFile(String fileId) async {
    await _box.delete(fileId);
  }

  // Mark synced
  Future<void> markSynced(String fileId) async {
    final file = _box.get(fileId);
    if (file != null) {
      file.isSynced = true;
      file.hasPendingChanges = false;
      await _box.put(fileId, file);
    }
  }

  // Conflict detection: check if same file was updated with newer timestamp
  Future<ConflictInfo?> detectConflict(
      String fileId, DateTime incomingTimestamp) async {
    final file = _box.get(fileId);
    if (file == null) return null;

    // If local has newer changes than incoming → conflict
    if (file.updatedAt.isAfter(incomingTimestamp) &&
        file.hasPendingChanges) {
      return ConflictInfo(
        conflictingVersionId: file.versions.last.id,
        conflictTimestamp: incomingTimestamp,
        resolution: 'keep_both',
      );
    }
    return null;
  }

  // Resolve conflict: latest wins (overwrite)
  Future<void> resolveConflictLatestWins(
      String fileId, FileModel incomingFile) async {
    final file = _box.get(fileId);
    if (file != null) {
      // Keep incoming if it's newer
      if (incomingFile.updatedAt.isAfter(file.updatedAt)) {
        incomingFile.conflicts
            .forEach((c) => c.resolved = true);
        await _box.put(fileId, incomingFile);
      } else {
        // Local is newer, mark conflicts resolved
        for (var c in file.conflicts) {
          c.resolved = true;
        }
        file.isSynced = true;
        await _box.put(fileId, file);
      }
    }
  }

  // Resolve conflict: keep both versions
  Future<void> resolveConflictKeepBoth(
      String fileId, FileVersion incomingVersion) async {
    final file = _box.get(fileId);
    if (file != null) {
      // Add the incoming version to the existing file
      file.versions.add(incomingVersion);
      for (var c in file.conflicts) {
        c.resolved = true;
      }
      file.isSynced = true;
      await _box.put(fileId, file);
    }
  }

  // Search
  List<FileModel> searchFiles(String query, String userId) {
    final q = query.toLowerCase();
    return _box.values
        .where((f) =>
            f.ownerId == userId && f.name.toLowerCase().contains(q))
        .toList();
  }

  // Filter by type
  List<FileModel> filterByType(FileType type, String userId) {
    return _box.values
        .where((f) => f.ownerId == userId && f.type == type)
        .toList();
  }

  // Get files with pending changes (for sync)
  List<FileModel> getPendingFiles(String userId) {
    return _box.values
        .where((f) => f.ownerId == userId && f.hasPendingChanges)
        .toList();
  }

  // Get files with conflicts
  List<FileModel> getConflictFiles(String userId) {
    return _box.values
        .where((f) => f.ownerId == userId && f.hasConflicts)
        .toList();
  }
}

final fileRepositoryProvider = Provider<FileRepository>((ref) {
  return FileRepository();
});
