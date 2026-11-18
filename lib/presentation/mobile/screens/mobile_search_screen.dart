import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/categories_provider.dart';
import '../../providers/content_provider.dart';
import '../../shared/widgets/category_chip.dart';
import '../../shared/widgets/video_card.dart';

class MobileSearchScreen extends ConsumerStatefulWidget {
  const MobileSearchScreen({super.key});

  @override
  ConsumerState<MobileSearchScreen> createState() => _MobileSearchScreenState();
}

class _MobileSearchScreenState extends ConsumerState<MobileSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _filterCategoryId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoriesProvider);
    final contentState = ref.watch(contentProvider);

    final query = _searchController.text.trim().toLowerCase();

    final filteredVideos = contentState.visibleItems.where((item) {
      if (_filterCategoryId != null && item.categoryId != _filterCategoryId) {
        return false;
      }
      if (query.isNotEmpty) {
        final matchesTitle = item.title.toLowerCase().contains(query);
        final matchesDesc = item.description?.toLowerCase().contains(query) ?? false;
        final matchesTag = item.tags.any((t) => t.toLowerCase().contains(query));
        return matchesTitle || matchesDesc || matchesTag;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Search Input Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      }
                    },
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(20),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        autofocus: false,
                        decoration: InputDecoration(
                          hintText: 'Search songs, cartoons, stories...',
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Category Filter Pills
            if (categoriesState.visibleCategories.isNotEmpty)
              SizedBox(
                height: 44,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: categoriesState.visibleCategories.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final isSelected = _filterCategoryId == null;
                      return GestureDetector(
                        onTap: () => setState(() => _filterCategoryId = null),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.primary.withAlpha(30),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'All Categories',
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppColors.text,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    final cat = categoriesState.visibleCategories[index - 1];
                    final isSelected = _filterCategoryId == cat.id;
                    return CategoryChip(
                      category: cat,
                      isSelected: isSelected,
                      compact: true,
                      onTap: () {
                        setState(() {
                          _filterCategoryId = isSelected ? null : cat.id;
                        });
                      },
                    );
                  },
                ),
              ),

            const SizedBox(height: 10),

            // Search Results Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Row(
                children: [
                  Text(
                    'Found ${filteredVideos.length} videos',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Search Results Grid
            Expanded(
              child: filteredVideos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 64,
                            color: AppColors.textLight.withAlpha(120),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No matching videos found',
                            style: AppTypography.titleLarge.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Try searching for "bunny", "farm", "songs" or "rhymes"',
                            style: TextStyle(color: AppColors.textLight, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.82,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      itemCount: filteredVideos.length,
                      itemBuilder: (context, index) {
                        final video = filteredVideos[index];
                        return VideoCard(
                          item: video,
                          width: double.infinity,
                          onTap: () => context.push('/video/${video.id}'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
