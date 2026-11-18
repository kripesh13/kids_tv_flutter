import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/category_model.dart';

class CategoryFormDialog extends StatefulWidget {
  final CategoryModel? initialCategory;
  final ValueChanged<CategoryModel> onSave;

  const CategoryFormDialog({
    super.key,
    this.initialCategory,
    required this.onSave,
  });

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _slugController;
  late TextEditingController _descriptionController;
  late TextEditingController _thumbnailController;
  late String _selectedIconName;
  late String _selectedColorHex;
  late bool _isFeatured;
  late bool _isVisible;
  late bool _requiresLogin;
  late bool _allowFavorites;
  late bool _allowSharing;
  late int _displayOrder;

  final List<String> _availableIcons = [
    'category',
    'music_note',
    'queue_music',
    'cruelty_free',
    'sports_soccer',
    'school',
    'auto_stories',
    'live_tv',
    'smart_display',
    'movie',
    'theater_comedy',
    'explore',
    'star',
  ];

  final List<String> _availableColors = [
    '#6657E8',
    '#FFB84D',
    '#FF6B81',
    '#42C98A',
    '#00D2D3',
    '#FF9F43',
    '#54A0FF',
    '#5F27CD',
    '#FF4757',
    '#2ED573',
  ];

  @override
  void initState() {
    super.initState();
    final cat = widget.initialCategory;
    _nameController = TextEditingController(text: cat?.name ?? '');
    _slugController = TextEditingController(text: cat?.slug ?? '');
    _descriptionController = TextEditingController(text: cat?.description ?? '');
    _thumbnailController = TextEditingController(text: cat?.thumbnailUrl ?? '');
    _selectedIconName = cat?.iconName ?? 'category';
    _selectedColorHex = cat?.colorHex ?? '#6657E8';
    _isFeatured = cat?.isFeatured ?? false;
    _isVisible = cat?.isVisible ?? true;
    _requiresLogin = cat?.requiresLogin ?? false;
    _allowFavorites = cat?.allowFavorites ?? true;
    _allowSharing = cat?.allowSharing ?? true;
    _displayOrder = cat?.displayOrder ?? 0;

    _nameController.addListener(() {
      if (widget.initialCategory == null) {
        final generated = _nameController.text
            .trim()
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9]+'), '-');
        _slugController.text = generated;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _descriptionController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final category = CategoryModel(
        id: widget.initialCategory?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        slug: _slugController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        iconName: _selectedIconName,
        thumbnailUrl: _thumbnailController.text.trim().isNotEmpty
            ? _thumbnailController.text.trim()
            : null,
        colorHex: _selectedColorHex,
        displayOrder: _displayOrder,
        isFeatured: _isFeatured,
        isVisible: _isVisible,
        requiresLogin: _requiresLogin,
        allowFavorites: _allowFavorites,
        allowSharing: _allowSharing,
        createdAt: widget.initialCategory?.createdAt ?? now,
        updatedAt: now,
      );

      widget.onSave(category);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialCategory != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
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
                        isEditing ? 'Edit Category' : 'New Category',
                        style: AppTypography.headlineMedium,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Category Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Category Name *',
                      hintText: 'e.g. Rhymes, Cartoons, Sports',
                    ),
                    validator: (v) => v?.trim().isEmpty == true ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 12),

                  // Slug
                  TextFormField(
                    controller: _slugController,
                    decoration: const InputDecoration(
                      labelText: 'URL Slug *',
                      hintText: 'e.g. rhymes, cartoons, sports',
                    ),
                    validator: (v) => v?.trim().isEmpty == true ? 'Slug is required' : null,
                  ),
                  const SizedBox(height: 12),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Short description for kids and parents',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),

                  // Thumbnail URL
                  TextFormField(
                    controller: _thumbnailController,
                    decoration: const InputDecoration(
                      labelText: 'Thumbnail Image URL',
                      hintText: 'https://...',
                      prefixIcon: Icon(Icons.image_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Icon Picker
                  const Text('Select Category Icon:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableIcons.map((iconName) {
                      final isSel = _selectedIconName == iconName;
                      final dummyCat = CategoryModel(
                        id: '',
                        name: '',
                        slug: '',
                        iconName: iconName,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      );
                      return ChoiceChip(
                        avatar: Icon(dummyCat.icon, size: 18),
                        label: Text(iconName),
                        selected: isSel,
                        onSelected: (val) {
                          if (val) setState(() => _selectedIconName = iconName);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Color Picker
                  const Text('Select Theme Color:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: _availableColors.map((hex) {
                      final isSel = _selectedColorHex == hex;
                      final color = Color(int.parse(hex.replaceAll('#', '0xFF')));
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColorHex = hex),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSel
                                ? Border.all(color: Colors.black, width: 3)
                                : null,
                          ),
                          child: isSel
                              ? const Icon(Icons.check, size: 18, color: Colors.white)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  // Category Access & Visibility Settings Container
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cardSecondary,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withAlpha(40)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          child: Text(
                            'Category Settings & Access Control',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        SwitchListTile(
                          title: const Text('Enable Category', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          subtitle: const Text('Visible across mobile and TV apps', style: TextStyle(fontSize: 12)),
                          value: _isVisible,
                          activeThumbColor: AppColors.primary,
                          onChanged: (val) => setState(() => _isVisible = val),
                        ),
                        SwitchListTile(
                          title: Row(
                            children: [
                              const Text('Require User Login', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withAlpha(40),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'GUEST GATE',
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                                ),
                              ),
                            ],
                          ),
                          subtitle: const Text('Guests must sign in to browse or watch this category', style: TextStyle(fontSize: 12)),
                          value: _requiresLogin,
                          activeThumbColor: AppColors.secondary,
                          onChanged: (val) => setState(() => _requiresLogin = val),
                        ),
                        SwitchListTile(
                          title: const Text('Show on Homepage', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          subtitle: const Text('Feature prominently on the home screen carousel', style: TextStyle(fontSize: 12)),
                          value: _isFeatured,
                          activeThumbColor: AppColors.primary,
                          onChanged: (val) => setState(() => _isFeatured = val),
                        ),
                        SwitchListTile(
                          title: const Text('Allow Favorites', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          subtitle: const Text('Users can add items from this category to favorites', style: TextStyle(fontSize: 12)),
                          value: _allowFavorites,
                          activeThumbColor: AppColors.primary,
                          onChanged: (val) => setState(() => _allowFavorites = val),
                        ),
                        SwitchListTile(
                          title: const Text('Allow Sharing', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          subtitle: const Text('Allow users and guests to share links to this content', style: TextStyle(fontSize: 12)),
                          value: _allowSharing,
                          activeThumbColor: AppColors.primary,
                          onChanged: (val) => setState(() => _allowSharing = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Actions
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(isEditing ? 'Save Changes' : 'Create Category'),
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
