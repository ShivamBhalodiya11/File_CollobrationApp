import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/file_model.dart';
import '../repositories/file_repository.dart';
import '../services/auth_service.dart';

// ------- State -------
class FilesState {
  final List<FileModel> files;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final FileType? filterType;
  final bool? filterShared; // null = all, true = shared, false = personal

  const FilesState({
    this.files = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.filterType,
    this.filterShared,
  });

  FilesState copyWith({
    List<FileModel>? files,
    bool? isLoading,
    String? error,
    String? searchQuery,
    FileType? filterType,
    bool? filterShared,
    bool clearFilter = false,
    bool clearError = false,
    bool clearSharedFilter = false,
  }) {
    return FilesState(
      files: files ?? this.files,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      filterType: clearFilter ? null : filterType ?? this.filterType,
      filterShared: clearSharedFilter
          ? null
          : filterShared ?? this.filterShared,
    );
  }

  List<FileModel> get filteredFiles {
    var result = files;

    if (searchQuery.isNotEmpty) {
      result = result
          .where((f) =>
              f.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    if (filterType != null) {
      result = result.where((f) => f.type == filterType).toList();
    }

    if (filterShared != null) {
      result = result.where((f) => f.isShared == filterShared).toList();
    }

    return result;
  }
}

// ------- Notifier -------
class FilesNotifier extends StateNotifier<FilesState> {
  final FileRepository _repo;
  final AuthService _auth;

  FilesNotifier(this._repo, this._auth) : super(const FilesState()) {
    loadFiles();
  }

  String get _userId => _auth.userId ?? '';

  void loadFiles() {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final files = _repo.getFilesByUser(_userId);
      state = state.copyWith(files: files, isLoading: false);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: e.toString(), files: []);
    }
  }

  Future<void> addFile(FileModel file) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repo.addFile(file);
      loadFiles();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateFile(FileModel file, String changeNote) async {
    try {
      final newVersionNumber = file.currentVersionNumber + 1;
      final newVersion = FileVersion(
        versionNumber: newVersionNumber,
        timestamp: DateTime.now(),
        authorId: _auth.userId ?? '',
        authorEmail: _auth.userEmail ?? '',
        changeNote: changeNote,
      );
      await _repo.addVersion(file.id, newVersion);
      await _repo.updateFile(file);
      loadFiles();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> addComment(String fileId, String text) async {
    try {
      final comment = FileComment(
        text: text,
        timestamp: DateTime.now(),
        authorId: _auth.userId ?? '',
        authorEmail: _auth.userEmail ?? '',
      );
      await _repo.addComment(fileId, comment);
      loadFiles();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteComment(String fileId, String commentId) async {
    try {
      await _repo.deleteComment(fileId, commentId);
      loadFiles();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> shareFile(String fileId, List<String> emails) async {
    try {
      await _repo.shareFile(fileId, emails);
      loadFiles();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> unshareFile(String fileId) async {
    try {
      await _repo.unshareFile(fileId);
      loadFiles();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteFile(String fileId) async {
    try {
      await _repo.deleteFile(fileId);
      loadFiles();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> simulateSync() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 2)); // Simulate network
    try {
      final pending = _repo.getPendingFiles(_userId);
      for (final file in pending) {
        // Simulate conflict: randomly create a conflict for demo
        if (pending.indexOf(file) == 0 && pending.length > 1) {
          final conflictInfo = ConflictInfo(
            conflictingVersionId: file.versions.isNotEmpty
                ? file.versions.last.id
                : 'mock_id',
            conflictTimestamp: DateTime.now()
                .subtract(const Duration(minutes: 5)),
            resolution: 'keep_both',
          );
          file.conflicts.add(conflictInfo);
        }
        await _repo.markSynced(file.id);
      }
      loadFiles();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> resolveConflict(
      String fileId, String strategy, FileVersion? incomingVersion) async {
    try {
      if (strategy == 'latest_wins') {
        final file = _repo.getFileById(fileId);
        if (file != null) {
          await _repo.resolveConflictLatestWins(fileId, file);
        }
      } else if (strategy == 'keep_both' && incomingVersion != null) {
        await _repo.resolveConflictKeepBoth(fileId, incomingVersion);
      }
      loadFiles();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setFilterType(FileType? type) {
    state = state.copyWith(filterType: type, clearFilter: type == null);
  }

  void setFilterShared(bool? shared) {
    state = state.copyWith(
        filterShared: shared, clearSharedFilter: shared == null);
  }

  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      clearFilter: true,
      clearSharedFilter: true,
    );
  }

  FileModel? getFileById(String id) => _repo.getFileById(id);

  List<FileModel> getSharedFiles() => _repo.getSharedFiles(_userId);

  List<FileModel> getReceivedFiles() {
    final email = _auth.userEmail ?? '';
    return _repo.getReceivedFiles(email);
  }

  List<FileModel> getPendingFiles() => _repo.getPendingFiles(_userId);
  List<FileModel> getConflictFiles() => _repo.getConflictFiles(_userId);
}

// ------- Providers -------
final filesProvider =
    StateNotifierProvider<FilesNotifier, FilesState>((ref) {
  final repo = ref.watch(fileRepositoryProvider);
  final auth = ref.watch(authServiceProvider);
  return FilesNotifier(repo, auth);
});

final fileByIdProvider = Provider.family<FileModel?, String>((ref, id) {
  return ref.watch(filesProvider.notifier).getFileById(id);
});
