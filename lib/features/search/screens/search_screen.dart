import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/file_model.dart';
import '../../../core/providers/files_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/file_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filesState = ref.watch(filesProvider);
    final notifier = ref.read(filesProvider.notifier);
    final results = filesState.filteredFiles;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Search & Filter', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('Find files quickly', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  // Search Bar
                  TextField(
                    key: const Key('search_input'),
                    controller: _searchCtrl,
                    onChanged: (v) => notifier.setSearch(v),
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search by file name...',
                      hintStyle: const TextStyle(color: AppTheme.textMuted),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textMuted),
                      suffixIcon: filesState.searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, color: AppTheme.textMuted),
                              onPressed: () {
                                _searchCtrl.clear();
                                notifier.setSearch('');
                              },
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Filter Row - File Type
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'All Types',
                          isSelected: filesState.filterType == null,
                          onTap: () => notifier.setFilterType(null),
                          color: AppTheme.primary,
                        ),
                        ...FileType.values.map((t) => _FilterChip(
                          label: '${t.icon} ${t.label}',
                          isSelected: filesState.filterType == t,
                          onTap: () => notifier.setFilterType(filesState.filterType == t ? null : t),
                          color: AppTheme.fileTypeColor(t),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Filter Row - Shared
                  Row(children: [
                    _FilterChip(
                      label: 'All Files',
                      isSelected: filesState.filterShared == null,
                      onTap: () => notifier.setFilterShared(null),
                      color: AppTheme.primary,
                    ),
                    _FilterChip(
                      label: '🔗 Shared',
                      isSelected: filesState.filterShared == true,
                      onTap: () => notifier.setFilterShared(filesState.filterShared == true ? null : true),
                      color: AppTheme.secondary,
                    ),
                    _FilterChip(
                      label: '🔒 Personal',
                      isSelected: filesState.filterShared == false,
                      onTap: () => notifier.setFilterShared(filesState.filterShared == false ? null : false),
                      color: AppTheme.info,
                    ),
                    const Spacer(),
                    if (filesState.filterType != null || filesState.filterShared != null || filesState.searchQuery.isNotEmpty)
                      TextButton.icon(
                        onPressed: () {
                          _searchCtrl.clear();
                          notifier.clearFilters();
                        },
                        icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
                        label: const Text('Clear', style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(foregroundColor: AppTheme.accent),
                      ),
                  ]),

                  // Results count
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${results.length} result${results.length != 1 ? 's' : ''} found',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),

            // Results
            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Text('🔍', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text(
                          filesState.searchQuery.isEmpty && filesState.filterType == null && filesState.filterShared == null
                              ? 'Start typing to search'
                              : 'No files match your search',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text('Try adjusting your search or filters', style: Theme.of(context).textTheme.bodyMedium),
                      ]),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: results.length,
                      itemBuilder: (ctx, i) => FileCard(file: results[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;
  const _FilterChip({required this.label, required this.isSelected, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : AppTheme.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color.withOpacity(0.6) : Colors.white.withOpacity(0.08), width: isSelected ? 1.5 : 1),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? color : AppTheme.textMuted, fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
      ),
    );
  }
}
