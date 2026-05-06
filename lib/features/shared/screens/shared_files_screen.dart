import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/files_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/file_card.dart';

class SharedFilesScreen extends ConsumerWidget {
  const SharedFilesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(filesProvider); // rebuild on changes
    final notifier = ref.watch(filesProvider.notifier);
    final myShared = notifier.getSharedFiles();
    final received = notifier.getReceivedFiles();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppTheme.secondary, AppTheme.primary]),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.share_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Text('Shared Files', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800)),
                    ]),
                    const SizedBox(height: 6),
                    Text('Files you\'ve shared and received', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 20),
                    // Summary row
                    Row(children: [
                      _SummaryCard(icon: Icons.upload_rounded, label: 'Shared by me', count: myShared.length, color: AppTheme.secondary),
                      const SizedBox(width: 12),
                      _SummaryCard(icon: Icons.download_rounded, label: 'Received', count: received.length, color: AppTheme.info),
                    ]),
                  ],
                ).animate().fadeIn(duration: 400.ms),
              ),
            ),

            // My Shared Files
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(children: [
                  const Icon(Icons.upload_rounded, color: AppTheme.secondary, size: 18),
                  const SizedBox(width: 8),
                  Text('Shared by Me', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
            if (myShared.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: _EmptyState(
                    icon: '📤',
                    title: 'Nothing shared yet',
                    subtitle: 'Open a file and tap Share to share with teammates',
                    color: AppTheme.secondary,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => FileCard(file: myShared[i]),
                    childCount: myShared.length,
                  ),
                ),
              ),

            // Received Files
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(children: [
                  const Icon(Icons.download_rounded, color: AppTheme.info, size: 18),
                  const SizedBox(width: 8),
                  Text('Received Files', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
            if (received.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: _EmptyState(
                    icon: '📥',
                    title: 'No files received',
                    subtitle: 'Files shared with your email will appear here',
                    color: AppTheme.info,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => FileCard(file: received[i]),
                    childCount: received.length,
                  ),
                ),
              ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  const _SummaryCard({required this.icon, required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(count.toString(), style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w800)),
            Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
          ]),
        ]),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color color;
  const _EmptyState({required this.icon, required this.title, required this.subtitle, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(children: [
        Text(icon, style: const TextStyle(fontSize: 36)),
        const SizedBox(height: 10),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
      ]),
    );
  }
}
