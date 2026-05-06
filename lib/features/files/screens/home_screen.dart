import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/files_provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/file_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filesState = ref.watch(filesProvider);
    final auth = ref.watch(authServiceProvider);
    final isOnline = ref.watch(isOnlineProvider).value ?? false;
    final files = filesState.files;
    final conflictFiles =
        ref.watch(filesProvider.notifier).getConflictFiles();
    final pendingFiles =
        ref.watch(filesProvider.notifier).getPendingFiles();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good ${_greeting()},',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                auth.displayName ??
                                    auth.userEmail?.split('@').first ??
                                    'User',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge
                                    ?.copyWith(
                                        fontWeight: FontWeight.w800),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Avatar + Menu
                        GestureDetector(
                          onTap: () => _showProfileMenu(context, ref),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppTheme.primary,
                                  AppTheme.secondary
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                (auth.displayName?.isNotEmpty == true
                                        ? auth.displayName!
                                        : auth.userEmail ?? 'U')[0]
                                    .toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Stats Row
                    _StatsRow(
                      totalFiles: files.length,
                      sharedFiles:
                          files.where((f) => f.isShared).length,
                      pendingSync: pendingFiles.length,
                      conflicts: conflictFiles.length,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),
            ),

            // Sync Banner
            if (pendingFiles.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: GestureDetector(
                    onTap: isOnline
                        ? () => _handleSync(context, ref)
                        : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppTheme.primary.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.sync_rounded,
                              color: AppTheme.primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${pendingFiles.length} file(s) pending sync',
                              style: const TextStyle(
                                color: AppTheme.primaryLight,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Text(
                            isOnline ? 'Sync Now →' : 'Offline',
                            style: TextStyle(
                              color: isOnline
                                  ? AppTheme.secondary
                                  : AppTheme.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Conflict Banner
            if (conflictFiles.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppTheme.warning.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: AppTheme.warning, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          '${conflictFiles.length} conflict(s) detected',
                          style: const TextStyle(
                            color: AppTheme.warning,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Files Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  children: [
                    Text(
                      'My Files',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    Text(
                      '${files.length} files',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),

            // Loading
            if (filesState.isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.primary),
                  ),
                ),
              )
            // Empty state
            else if (files.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      const Text('📁', style: TextStyle(fontSize: 64)),
                      const SizedBox(height: 16),
                      Text(
                        'No files yet',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the + button to add your first file',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ).animate().fadeIn(),
                ),
              )
            // File list
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => FileCard(file: files[i]),
                    childCount: files.length,
                  ),
                ),
              ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  void _handleSync(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(filesProvider.notifier);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🔄 Syncing files...')),
    );
    await notifier.simulateSync();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Sync complete!'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  void _showProfileMenu(BuildContext context, WidgetRef ref) {
    final auth = ref.read(authServiceProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 36,
              backgroundColor: AppTheme.primary,
              child: Text(
                (auth.displayName?.isNotEmpty == true
                        ? auth.displayName!
                        : auth.userEmail ?? 'U')[0]
                    .toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              auth.displayName ?? 'User',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              auth.userEmail ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.logout_rounded,
                  color: AppTheme.accent),
              title: const Text('Sign Out',
                  style: TextStyle(color: AppTheme.accent)),
              onTap: () async {
                Navigator.pop(ctx);
                await auth.signOut();
                if (context.mounted) context.go('/login');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int totalFiles;
  final int sharedFiles;
  final int pendingSync;
  final int conflicts;

  const _StatsRow({
    required this.totalFiles,
    required this.sharedFiles,
    required this.pendingSync,
    required this.conflicts,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          label: 'Files',
          value: totalFiles.toString(),
          color: AppTheme.primary,
          icon: Icons.folder_rounded,
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'Shared',
          value: sharedFiles.toString(),
          color: AppTheme.secondary,
          icon: Icons.share_rounded,
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'Pending',
          value: pendingSync.toString(),
          color: AppTheme.info,
          icon: Icons.cloud_upload_rounded,
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'Conflicts',
          value: conflicts.toString(),
          color: conflicts > 0 ? AppTheme.warning : AppTheme.textMuted,
          icon: Icons.warning_amber_rounded,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
