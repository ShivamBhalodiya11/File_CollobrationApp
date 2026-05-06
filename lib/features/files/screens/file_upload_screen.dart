import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/file_model.dart';
import '../../../core/providers/files_provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/gradient_button.dart';
import '../../../widgets/app_text_field.dart';

class FileUploadScreen extends ConsumerStatefulWidget {
  const FileUploadScreen({super.key});

  @override
  ConsumerState<FileUploadScreen> createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends ConsumerState<FileUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  FileType _selectedType = FileType.document;
  int _fileSizeKb = 256;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _uploadFile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final auth = ref.read(authServiceProvider);
    final now = DateTime.now();

    final initialVersion = FileVersion(
      versionNumber: 1,
      timestamp: now,
      authorId: auth.userId ?? '',
      authorEmail: auth.userEmail ?? '',
      changeNote: 'Initial upload',
    );

    final file = FileModel(
      name: _nameCtrl.text.trim(),
      type: _selectedType,
      description: _descCtrl.text.trim(),
      ownerId: auth.userId ?? '',
      ownerEmail: auth.userEmail ?? '',
      versions: [initialVersion],
      fileSizeKb: _fileSizeKb,
    );

    await ref.read(filesProvider.notifier).addFile(file);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ File added successfully!'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Add New File'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // File type selector visual
                _FileTypeVisual(type: _selectedType)
                    .animate()
                    .fadeIn()
                    .scale(begin: const Offset(0.8, 0.8)),

                const SizedBox(height: 24),

                // File Name
                Text('File Details',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),

                AppTextField(
                  id: 'upload_name',
                  controller: _nameCtrl,
                  label: 'File Name',
                  hint: 'e.g. Project Report Q1',
                  prefixIcon: Icons.drive_file_rename_outline_rounded,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'File name is required';
                    }
                    if (v.length > 100) {
                      return 'Name too long (max 100 chars)';
                    }
                    // Duplicate check
                    final existing = ref
                        .read(filesProvider)
                        .files
                        .where((f) =>
                            f.name.toLowerCase() == v.trim().toLowerCase())
                        .toList();
                    if (existing.isNotEmpty) {
                      return 'A file with this name already exists';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                AppTextField(
                  id: 'upload_description',
                  controller: _descCtrl,
                  label: 'Description (optional)',
                  hint: 'Brief description of this file...',
                  prefixIcon: Icons.description_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // File Type
                Text('File Type',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                _FileTypeGrid(
                  selected: _selectedType,
                  onSelect: (t) => setState(() => _selectedType = t),
                ),
                const SizedBox(height: 24),

                // Mock file size slider
                Text('Mock File Size',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${_fileSizeKb < 1024 ? '$_fileSizeKb KB' : '${(_fileSizeKb / 1024).toStringAsFixed(1)} MB'}',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: _fileSizeKb.toDouble(),
                        min: 1,
                        max: 10240,
                        divisions: 100,
                        activeColor: AppTheme.primary,
                        inactiveColor: AppTheme.bgCardLight,
                        onChanged: (v) =>
                            setState(() => _fileSizeKb = v.toInt()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                GradientButton(
                  id: 'upload_submit',
                  onPressed: _isLoading ? null : _uploadFile,
                  isLoading: _isLoading,
                  child: const Text('Add File'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FileTypeVisual extends StatelessWidget {
  final FileType type;
  const _FileTypeVisual({required this.type});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.fileTypeColor(type);
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [color.withOpacity(0.3), color.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: color.withOpacity(0.4), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(type.icon, style: const TextStyle(fontSize: 48)),
            Text(
              type.label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FileTypeGrid extends StatelessWidget {
  final FileType selected;
  final ValueChanged<FileType> onSelect;

  const _FileTypeGrid({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: FileType.values.map((type) {
        final isSelected = type == selected;
        final color = AppTheme.fileTypeColor(type);
        return GestureDetector(
          onTap: () => onSelect(type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withOpacity(0.2)
                  : AppTheme.bgCardLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? color.withOpacity(0.7)
                    : Colors.white.withOpacity(0.08),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(type.icon, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  type.label,
                  style: TextStyle(
                    color:
                        isSelected ? color : AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
