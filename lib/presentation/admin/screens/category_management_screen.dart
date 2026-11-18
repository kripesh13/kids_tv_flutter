import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/category_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/categories_provider.dart';
import '../dialogs/category_form_dialog.dart';

class CategoryManagementScreen extends ConsumerWidget {
  const CategoryManagementScreen({super.key});

  void _openCategoryDialog(BuildContext context, WidgetRef ref, [CategoryModel? category]) {
    showDialog(
      context: context,
      builder: (ctx) => CategoryFormDialog(
        initialCategory: category,
        onSave: (saved) {
          ref.read(categoriesProvider.notifier).saveCategory(saved);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(category == null
                  ? 'Category "${saved.name}" added successfully!'
                  : 'Category "${saved.name}" updated successfully!'),
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, CategoryModel category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category?'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              ref.read(categoriesProvider.notifier).deleteCategory(category.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Category "${category.name}" deleted.')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(categoriesProvider);
    final authState = ref.watch(authProvider);
    final canDelete = authState.user?.role.canDeleteCategories ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Category Management', style: AppTypography.headlineLarge),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('New Category'),
              onPressed: () => _openCategoryDialog(context, ref),
            ),
          ),
        ],
      ),
      body: categoriesState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : categoriesState.categories.isEmpty
              ? const Center(child: Text('No categories found. Create one above!'))
              : Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withAlpha(50)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Tip: Drag & drop items by the handle to reorder categories. TV and Mobile home screens will automatically reflect the order!',
                              style: TextStyle(color: AppColors.primary, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ReorderableListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: categoriesState.categories.length,
                        onReorder: (oldIndex, newIndex) {
                          ref
                              .read(categoriesProvider.notifier)
                              .reorderCategories(oldIndex, newIndex);
                        },
                        itemBuilder: (context, index) {
                          final category = categoriesState.categories[index];
                          return Card(
                            key: ValueKey(category.id),
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ReorderableDragStartListener(
                                    index: index,
                                    child: const Icon(Icons.drag_indicator, color: Colors.grey),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: category.color.withAlpha(40),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(category.icon, color: category.color, size: 22),
                                  ),
                                ],
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    category.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (category.isFeatured) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'FEATURED',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  if (category.requiresLogin)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade400,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.lock_rounded, size: 10, color: Colors.white),
                                          SizedBox(width: 3),
                                          Text(
                                            'LOGIN REQUIRED',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Text(
                                'Slug: /${category.slug} • Order: ${category.displayOrder}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Visibility Switch
                                  IconButton(
                                    icon: Icon(
                                      category.isVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: category.isVisible
                                          ? AppColors.primary
                                          : Colors.grey,
                                    ),
                                    tooltip: category.isVisible ? 'Visible' : 'Hidden',
                                    onPressed: () {
                                      ref
                                          .read(categoriesProvider.notifier)
                                          .toggleVisibility(category.id);
                                    },
                                  ),

                                  // Edit Button
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, color: AppColors.info),
                                    tooltip: 'Edit',
                                    onPressed: () =>
                                        _openCategoryDialog(context, ref, category),
                                  ),

                                  // Delete Button
                                  if (canDelete)
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                      tooltip: 'Delete',
                                      onPressed: () =>
                                          _confirmDelete(context, ref, category),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
