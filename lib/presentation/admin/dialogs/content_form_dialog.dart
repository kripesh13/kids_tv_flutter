import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/content_item_model.dart';
import '../../../domain/enums/content_type.dart';

class ContentFormDialog extends StatefulWidget {
  final ContentItemModel? initialItem;
  final List<CategoryModel> categories;
  final ValueChanged<ContentItemModel> onSave;

  const ContentFormDialog({
    super.key,
    this.initialItem,
    required this.categories,
    required this.onSave,
  });

  @override
  State<ContentFormDialog> createState() => _ContentFormDialogState();
}

class _ContentFormDialogState extends State<ContentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _thumbnailController;
  late TextEditingController _sourceUrlController;
  late TextEditingController _durationController;
  late TextEditingController _tagsController;
  late String? _selectedCategoryId;
  late ContentType _selectedContentType;
  late bool _isFeatured;
  late bool _isVisible;
  late int _displayOrder;

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;
    _titleController = TextEditingController(text: item?.title ?? '');
    _descController = TextEditingController(text: item?.description ?? '');
    _thumbnailController = TextEditingController(text: item?.thumbnailUrl ?? '');
    _sourceUrlController = TextEditingController(text: item?.sourceUrl ?? '');
    _durationController = TextEditingController(
      text: item != null && item.durationSeconds > 0
          ? '${item.durationSeconds ~/ 60}'
          : '',
    );
    _tagsController = TextEditingController(text: item?.tags.join(', ') ?? '');
    _selectedCategoryId = item?.categoryId ??
        (widget.categories.isNotEmpty ? widget.categories.first.id : null);
    _selectedContentType = item?.contentType ?? ContentType.video;
    _isFeatured = item?.isFeatured ?? false;
    _isVisible = item?.isVisible ?? true;
    _displayOrder = item?.displayOrder ?? 0;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _thumbnailController.dispose();
    _sourceUrlController.dispose();
    _durationController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final minutes = int.tryParse(_durationController.text.trim()) ?? 0;
      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final item = ContentItemModel(
        id: widget.initialItem?.id ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descController.text.trim().isNotEmpty
            ? _descController.text.trim()
            : null,
        thumbnailUrl: _thumbnailController.text.trim(),
        categoryId: _selectedCategoryId,
        contentType: _selectedContentType,
        sourceUrl: _sourceUrlController.text.trim(),
        durationSeconds: minutes * 60,
        isFeatured: _isFeatured,
        isVisible: _isVisible,
        displayOrder: _displayOrder,
        viewsCount: widget.initialItem?.viewsCount ?? 0,
        tags: tags,
        createdAt: widget.initialItem?.createdAt ?? now,
        updatedAt: now,
      );

      widget.onSave(item);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialItem != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing ? 'Edit Content' : 'Add Universal Content',
                        style: AppTypography.headlineLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Title
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title *',
                      hintText: 'e.g. Big Buck Bunny Episode 1',
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 14),

                  // Content Type Selector
                  DropdownButtonFormField<ContentType>(
                    initialValue: _selectedContentType,
                    decoration: const InputDecoration(
                      labelText: 'Content Type *',
                    ),
                    items: ContentType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Icon(type.icon, size: 20, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(type.label),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedContentType = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  // Category Selector
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Category *',
                    ),
                    items: widget.categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat.id,
                        child: Row(
                          children: [
                            Icon(cat.icon, size: 18, color: cat.color),
                            const SizedBox(width: 8),
                            Text(cat.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedCategoryId = val),
                    validator: (v) => v == null ? 'Please select a category' : null,
                  ),
                  const SizedBox(height: 14),

                  // Source URL
                  TextFormField(
                    controller: _sourceUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Source Video URL (MP4, HLS m3u8, or YouTube) *',
                      hintText: 'https://.../video.mp4 or .m3u8',
                      prefixIcon: Icon(Icons.link_rounded),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Source URL is required' : null,
                  ),
                  const SizedBox(height: 14),

                  // Thumbnail URL
                  TextFormField(
                    controller: _thumbnailController,
                    decoration: const InputDecoration(
                      labelText: 'Thumbnail Image URL *',
                      hintText: 'https://images.unsplash.com/...',
                      prefixIcon: Icon(Icons.image_outlined),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Thumbnail URL is required' : null,
                  ),
                  const SizedBox(height: 14),

                  // Row: Duration in minutes & Tags
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _durationController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Duration (minutes)',
                            hintText: 'e.g. 5',
                            prefixIcon: Icon(Icons.timer_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextFormField(
                          controller: _tagsController,
                          decoration: const InputDecoration(
                            labelText: 'Tags (comma separated)',
                            hintText: 'cartoon, bunny, funny',
                            prefixIcon: Icon(Icons.tag_rounded),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Description
                  TextFormField(
                    controller: _descController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter storyline or educational description',
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Switches
                  SwitchListTile(
                    title: const Text('Visible to Users & TV'),
                    subtitle: const Text('Instantly show or hide in all apps'),
                    value: _isVisible,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) => setState(() => _isVisible = val),
                  ),
                  SwitchListTile(
                    title: const Text('Featured Spotlight'),
                    subtitle: const Text('Highlight on TV & Mobile home sections'),
                    value: _isFeatured,
                    activeThumbColor: AppColors.secondary,
                    onChanged: (val) => setState(() => _isFeatured = val),
                  ),

                  const SizedBox(height: 20),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _submit,
                        child: Text(isEditing ? 'Save Changes' : 'Add Content Item'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
