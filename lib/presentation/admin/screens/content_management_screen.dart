import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/content_item_model.dart';
import '../../../domain/enums/content_type.dart';
import '../../providers/auth_provider.dart';
import '../../providers/categories_provider.dart';
import '../../providers/content_provider.dart';
import '../dialogs/content_form_dialog.dart';

class ContentManagementScreen extends ConsumerStatefulWidget {
  const ContentManagementScreen({super.key});

  @override
  ConsumerState<ContentManagementScreen> createState() =>
      _ContentManagementScreenState();
}

class _ContentManagementScreenState
    extends ConsumerState<ContentManagementScreen> {
  String? _filterCategoryId;
  ContentType? _filterContentType;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openContentDialog([ContentItemModel? item]) {
    final categories = ref.read(categoriesProvider).categories;
    showDialog(
      context: context,
      builder: (ctx) => ContentFormDialog(
        initialItem: item,
        categories: categories,
        onSave: (saved) {
          ref.read(contentProvider.notifier).saveContentItem(saved);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(item == null
                  ? 'Content item added!'
                  : 'Content item updated!'),
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(ContentItemModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Content?'),
        content: Text('Are you sure you want to delete "${item.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              ref.read(contentProvider.notifier).deleteContentItem(item.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('"${item.title}" removed.')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contentState = ref.watch(contentProvider);
    final categoriesState = ref.watch(categoriesProvider);
    final authState = ref.watch(authProvider);
    final canDelete = authState.user?.role.canDeleteContent ?? false;

    final q = _searchController.text.trim().toLowerCase();

    final filteredItems = contentState.items.where((i) {
      if (_filterCategoryId != null && i.categoryId != _filterCategoryId) {
        return false;
      }
      if (_filterContentType != null && i.contentType != _filterContentType) {
        return false;
      }
      if (q.isNotEmpty) {
        final matchesTitle = i.title.toLowerCase().contains(q);
        final matchesDesc = i.description?.toLowerCase().contains(q) ?? false;
        final matchesTag = i.tags.any((t) => t.toLowerCase().contains(q));
        return matchesTitle || matchesDesc || matchesTag;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Universal Content Management',
            style: AppTypography.headlineLarge),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Add Content'),
              onPressed: () => _openContentDialog(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter & Search Controls
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    // Search bar
                    Expanded(
                      flex: 4,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search by title, tag, or description...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Category dropdown
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String?>(
                        initialValue: _filterCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Filter Category',
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Categories'),
                          ),
                          ...categoriesState.categories.map((c) {
                            return DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            );
                          }),
                        ],
                        onChanged: (val) =>
                            setState(() => _filterCategoryId = val),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Content Type dropdown
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<ContentType?>(
                        initialValue: _filterContentType,
                        decoration: const InputDecoration(
                          labelText: 'Content Type',
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Types'),
                          ),
                          ...ContentType.values.map((t) {
                            return DropdownMenuItem(
                              value: t,
                              child: Text(t.label),
                            );
                          }),
                        ],
                        onChanged: (val) =>
                            setState(() => _filterContentType = val),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Count indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${filteredItems.length} content items',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Changes reflect on Mobile & TV instantly',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Content Items List
          Expanded(
            child: filteredItems.isEmpty
                ? const Center(child: Text('No content matching the filters.'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    itemCount: filteredItems.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      final category = categoriesState.categories
                          .where((c) => c.id == item.categoryId)
                          .firstOrNull;

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Thumbnail Preview
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  width: 110,
                                  height: 70,
                                  child: CachedNetworkImage(
                                    imageUrl: item.thumbnailUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (_, _) => Container(
                                        color: AppColors.cardSecondary),
                                    errorWidget: (_, _, _) => Container(
                                      color: Colors.grey.shade300,
                                      child: const Icon(Icons.broken_image),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Metadata
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        if (item.isFeatured) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.secondary,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: const Text(
                                              'FEATURED',
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        if (category != null) ...[
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color:
                                                  category.color.withAlpha(30),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              category.name,
                                              style: TextStyle(
                                                color: category.color,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                        Icon(item.contentType.icon,
                                            size: 14, color: AppColors.textLight),
                                        const SizedBox(width: 4),
                                        Text(
                                          item.contentType.label,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          '${item.viewsCount} views',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (item.description != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        item.description!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // Actions
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Featured toggle
                                  IconButton(
                                    icon: Icon(
                                      item.isFeatured
                                          ? Icons.star_rounded
                                          : Icons.star_border_rounded,
                                      color: item.isFeatured
                                          ? AppColors.secondary
                                          : Colors.grey,
                                    ),
                                    tooltip: item.isFeatured
                                        ? 'Unfeature'
                                        : 'Feature on Home',
                                    onPressed: () {
                                      ref
                                          .read(contentProvider.notifier)
                                          .toggleFeatured(item.id);
                                    },
                                  ),

                                  // Visibility toggle
                                  IconButton(
                                    icon: Icon(
                                      item.isVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: item.isVisible
                                          ? AppColors.primary
                                          : Colors.grey,
                                    ),
                                    tooltip: item.isVisible
                                        ? 'Visible'
                                        : 'Hidden',
                                    onPressed: () {
                                      ref
                                          .read(contentProvider.notifier)
                                          .toggleVisibility(item.id);
                                    },
                                  ),

                                  // Edit
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined,
                                        color: AppColors.info),
                                    tooltip: 'Edit',
                                    onPressed: () => _openContentDialog(item),
                                  ),

                                  // Delete
                                  if (canDelete)
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: AppColors.error),
                                      tooltip: 'Delete',
                                      onPressed: () => _confirmDelete(item),
                                    ),
                                ],
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
