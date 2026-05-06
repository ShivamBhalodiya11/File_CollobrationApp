import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/providers/files_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/services/connectivity_service.dart';

class ShellScaffold extends ConsumerWidget {
  final Widget child;
  const ShellScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider).value ?? false;
    final location = GoRouterState.of(context).matchedLocation;
    final pendingFiles = ref.watch(filesProvider.notifier).getPendingFiles();

    int currentIndex = 0;
    if (location.startsWith('/shared')) currentIndex = 1;
    if (location.startsWith('/search')) currentIndex = 2;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Stack(
        children: [
          child,
          // Connectivity Banner
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              height: isOnline ? 0 : 28,
              color: AppTheme.warning.withOpacity(0.9),
              child: const Center(
                child: Text(
                  '📡 Offline Mode — Changes will sync when connected',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.07),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.folder_rounded,
                  label: 'Files',
                  isSelected: currentIndex == 0,
                  badge: pendingFiles.isNotEmpty
                      ? pendingFiles.length.toString()
                      : null,
                  onTap: () => context.go('/home'),
                ),
                _NavItem(
                  icon: Icons.share_rounded,
                  label: 'Shared',
                  isSelected: currentIndex == 1,
                  onTap: () => context.go('/shared'),
                ),
                _NavItem(
                  icon: Icons.search_rounded,
                  label: 'Search',
                  isSelected: currentIndex == 2,
                  onTap: () => context.go('/search'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/upload'),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add File'),
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              elevation: 4,
            )
          : null,
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final String? badge;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isSelected ? AppTheme.primary : AppTheme.textMuted,
                  size: 26,
                ),
                if (badge != null)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppTheme.accent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        badge!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.primary : AppTheme.textMuted,
                fontSize: 11,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
