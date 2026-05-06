import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/models/file_model.dart';
import '../../../core/providers/files_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/app_text_field.dart';

class FileDetailsScreen extends ConsumerStatefulWidget {
  final String fileId;
  const FileDetailsScreen({super.key, required this.fileId});

  @override
  ConsumerState<FileDetailsScreen> createState() => _FileDetailsScreenState();
}

class _FileDetailsScreenState extends ConsumerState<FileDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _commentCtrl = TextEditingController();
  final _changeNoteCtrl = TextEditingController();
  bool _isAddingComment = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentCtrl.dispose();
    _changeNoteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final file = ref.watch(fileByIdProvider(widget.fileId));
    if (file == null) {
      return Scaffold(
        backgroundColor: AppTheme.bgDark,
        appBar: AppBar(title: const Text('File Details')),
        body: const Center(child: Text('File not found')),
      );
    }
    final color = AppTheme.fileTypeColor(file.type);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, inner) => [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppTheme.bgDark,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded),
                onPressed: () => _showShareDialog(context, file),
              ),
              PopupMenuButton<String>(
                color: AppTheme.bgCard,
                onSelected: (v) {
                  if (v == 'update') _showUpdateDialog(context, file);
                  if (v == 'delete') _confirmDelete(context, file);
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'update',
                    child: Row(children: [
                      Icon(Icons.edit_rounded, color: AppTheme.primary, size: 18),
                      SizedBox(width: 8),
                      Text('Update File', style: TextStyle(color: AppTheme.textPrimary)),
                    ]),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_rounded, color: AppTheme.accent, size: 18),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: AppTheme.accent)),
                    ]),
                  ),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.3), AppTheme.bgDark],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Text(file.type.icon, style: const TextStyle(fontSize: 56)),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        file.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _Chip(label: file.type.label, color: color),
                        if (file.isShared)
                          const _Chip(label: 'Shared', color: AppTheme.secondary),
                        if (file.hasConflicts)
                          const _Chip(label: '⚠ Conflict', color: AppTheme.warning),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.primary,
              labelColor: AppTheme.primary,
              unselectedLabelColor: AppTheme.textMuted,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Versions'),
                Tab(text: 'Comments'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _OverviewTab(file: file),
            _VersionsTab(file: file, onResolveConflict: (strategy) => _resolveConflict(file, strategy)),
            _CommentsTab(
              file: file,
              commentCtrl: _commentCtrl,
              isAdding: _isAddingComment,
              onAddComment: () => _addComment(file),
              onDeleteComment: (commentId) => _deleteComment(file, commentId),
            ),
          ],
        ),
      ),
    );
  }

  void _addComment(FileModel file) async {
    if (_commentCtrl.text.trim().isEmpty) return;
    setState(() => _isAddingComment = true);
    await ref.read(filesProvider.notifier).addComment(file.id, _commentCtrl.text.trim());
    _commentCtrl.clear();
    setState(() => _isAddingComment = false);
  }

  void _deleteComment(FileModel file, String commentId) async {
    await ref.read(filesProvider.notifier).deleteComment(file.id, commentId);
  }

  void _showUpdateDialog(BuildContext context, FileModel file) {
    _changeNoteCtrl.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('Update File', style: TextStyle(color: AppTheme.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This will create a new version.', style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            AppTextField(
              id: 'update_change_note',
              controller: _changeNoteCtrl,
              label: 'Change Note',
              hint: 'What changed in this version?',
              prefixIcon: Icons.edit_note_rounded,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(filesProvider.notifier).updateFile(
                    file,
                    _changeNoteCtrl.text.trim().isEmpty
                        ? 'File updated'
                        : _changeNoteCtrl.text.trim(),
                  );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ New version created!'), backgroundColor: AppTheme.success),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showShareDialog(BuildContext context, FileModel file) {
    final emailCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Share File', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (file.sharedWith.isNotEmpty)
              Wrap(
                spacing: 6,
                children: file.sharedWith
                    .map((e) => Chip(label: Text(e, style: const TextStyle(fontSize: 11)), deleteIcon: const Icon(Icons.close, size: 14)))
                    .toList(),
              ),
            const SizedBox(height: 12),
            AppTextField(
              id: 'share_email',
              controller: emailCtrl,
              label: 'Share with (email)',
              hint: 'colleague@example.com',
              prefixIcon: Icons.person_add_rounded,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (file.isShared)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref.read(filesProvider.notifier).unshareFile(file.id);
                        Navigator.pop(ctx);
                      },
                      style: OutlinedButton.styleFrom(foregroundColor: AppTheme.accent, side: const BorderSide(color: AppTheme.accent)),
                      child: const Text('Unshare'),
                    ),
                  ),
                if (file.isShared) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                    onPressed: () {
                      final email = emailCtrl.text.trim();
                      if (email.isNotEmpty) {
                        ref.read(filesProvider.notifier).shareFile(file.id, [email]);
                      }
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ File shared!'), backgroundColor: AppTheme.success),
                      );
                    },
                    child: const Text('Share'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _resolveConflict(FileModel file, String strategy) async {
    await ref.read(filesProvider.notifier).resolveConflict(file.id, strategy, null);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Conflict resolved: $strategy'), backgroundColor: AppTheme.success),
      );
    }
  }

  void _confirmDelete(BuildContext context, FileModel file) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('Delete File?', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text('This will permanently delete "${file.name}".', style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(filesProvider.notifier).deleteFile(file.id);
              context.pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// --------- Tabs ---------

class _OverviewTab extends StatelessWidget {
  final FileModel file;
  const _OverviewTab({required this.file});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d, yyyy • h:mm a');
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _InfoRow(label: 'Owner', value: file.ownerEmail),
        _InfoRow(label: 'Type', value: file.type.label),
        _InfoRow(label: 'Current Version', value: 'v${file.currentVersionNumber}'),
        _InfoRow(label: 'Total Versions', value: '${file.versions.length}'),
        _InfoRow(label: 'Comments', value: '${file.comments.length}'),
        _InfoRow(label: 'Size', value: file.fileSizeKb < 1024 ? '${file.fileSizeKb} KB' : '${(file.fileSizeKb / 1024).toStringAsFixed(1)} MB'),
        _InfoRow(label: 'Created', value: fmt.format(file.createdAt)),
        _InfoRow(label: 'Updated', value: fmt.format(file.updatedAt)),
        _InfoRow(label: 'Synced', value: file.isSynced ? '✅ Yes' : '⏳ Pending'),
        if (file.description.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Description', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppTheme.bgCard, borderRadius: BorderRadius.circular(12)),
            child: Text(file.description, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
        if (file.isShared && file.sharedWith.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Shared With', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: file.sharedWith
                .map((e) => Chip(
                      label: Text(e, style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary)),
                      backgroundColor: AppTheme.secondary.withOpacity(0.15),
                      side: BorderSide(color: AppTheme.secondary.withOpacity(0.3)),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _VersionsTab extends StatelessWidget {
  final FileModel file;
  final ValueChanged<String> onResolveConflict;
  const _VersionsTab({required this.file, required this.onResolveConflict});

  @override
  Widget build(BuildContext context) {
    final versions = file.versions.reversed.toList();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (file.hasConflicts) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.warning.withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Icons.warning_amber_rounded, color: AppTheme.warning, size: 20),
                  SizedBox(width: 8),
                  Text('Sync Conflict Detected', style: TextStyle(color: AppTheme.warning, fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 8),
                const Text('Same file was modified in multiple places. Choose a resolution strategy:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => onResolveConflict('latest_wins'),
                      style: OutlinedButton.styleFrom(foregroundColor: AppTheme.info, side: const BorderSide(color: AppTheme.info)),
                      child: const Text('Latest Wins', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => onResolveConflict('keep_both'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warning),
                      child: const Text('Keep Both', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (versions.isEmpty)
          const Center(child: Text('No versions yet', style: TextStyle(color: AppTheme.textMuted)))
        else
          ...versions.asMap().entries.map((e) {
            final v = e.value;
            final isLatest = e.key == 0;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isLatest ? AppTheme.primary.withOpacity(0.1) : AppTheme.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isLatest ? AppTheme.primary.withOpacity(0.3) : Colors.white.withOpacity(0.06)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: isLatest ? AppTheme.primary : AppTheme.bgCardLight,
                    child: Text('v${v.versionNumber}', style: TextStyle(color: isLatest ? Colors.white : AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(v.changeNote, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                          if (isLatest) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(4)),
                              child: const Text('LATEST', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ]),
                        const SizedBox(height: 2),
                        Text(v.authorEmail, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                        Text(DateFormat('MMM d, y • h:mm a').format(v.timestamp), style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: Duration(milliseconds: e.key * 60));
          }),
      ],
    );
  }
}

class _CommentsTab extends StatelessWidget {
  final FileModel file;
  final TextEditingController commentCtrl;
  final bool isAdding;
  final VoidCallback onAddComment;
  final ValueChanged<String> onDeleteComment;
  const _CommentsTab({required this.file, required this.commentCtrl, required this.isAdding, required this.onAddComment, required this.onDeleteComment});

  @override
  Widget build(BuildContext context) {
    final comments = file.comments.reversed.toList();
    return Column(
      children: [
        Expanded(
          child: comments.isEmpty
              ? const Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('💬', style: TextStyle(fontSize: 48)),
                    SizedBox(height: 12),
                    Text('No comments yet.\nBe the first to comment!', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textMuted)),
                  ]),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: comments.length,
                  itemBuilder: (ctx, i) {
                    final c = comments[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppTheme.bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.06))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: AppTheme.primary.withOpacity(0.3),
                              child: Text(c.authorEmail[0].toUpperCase(), style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(c.authorEmail, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12))),
                            Text(DateFormat('MMM d').format(c.timestamp), style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppTheme.textMuted, size: 16),
                              onPressed: () => onDeleteComment(c.id),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ]),
                          const SizedBox(height: 8),
                          Text(c.text, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
                        ],
                      ),
                    ).animate().fadeIn(delay: Duration(milliseconds: i * 50));
                  },
                ),
        ),
        // Comment Input
        Container(
          padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 16),
          decoration: BoxDecoration(color: AppTheme.bgCard, border: Border(top: BorderSide(color: Colors.white.withOpacity(0.07)))),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('comment_input'),
                  controller: commentCtrl,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    hintStyle: const TextStyle(color: AppTheme.textMuted),
                    filled: true,
                    fillColor: AppTheme.bgCardLight,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  maxLines: null,
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: isAdding ? null : onAddComment,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.primaryDark]),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: isAdding
                      ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
                      : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 6, top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
