import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/access_control_provider.dart';
import '../../providers/categories_provider.dart';
import '../../providers/content_provider.dart';
import '../../shared/widgets/category_chip.dart';
import '../../shared/widgets/error_state_widget.dart';
import '../../shared/widgets/kids_button.dart';
import '../../shared/widgets/video_card.dart';

class TvCategoriesScreen extends ConsumerStatefulWidget {
  final String? initialCategoryId;
  const TvCategoriesScreen({super.key, this.initialCategoryId});

  @override
  ConsumerState<TvCategoriesScreen> createState() => _TvCategoriesScreenState();
}

class _TvCategoriesScreenState extends ConsumerState<TvCategoriesScreen> {
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoriesProvider);
    final contentState = ref.watch(contentProvider);
    final accessControl = ref.watch(accessControlProvider);

    final categories = categoriesState.visibleCategories;
    if (_selectedCategoryId == null && categories.isNotEmpty) {
      _selectedCategoryId = categories.first.id;
    }

    final activeCategory = categories.where((c) => c.id == _selectedCategoryId).firstOrNull ??
        (categories.isNotEmpty ? categories.first : null);

    final isCategoryLocked = activeCategory != null &&
        activeCategory.requiresLogin &&
        !accessControl.canAccessCategory(requiresLogin: true);

    final videos = activeCategory != null
        ? contentState.itemsForCategory(activeCategory.id)
        : contentState.visibleItems;

    return Scaffold(
      backgroundColor: AppColors.tvBackground,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Active category details
            Row(
              children: [
                Text(
                  'Browse Categories',
                  style: AppTypography.tvDisplay.copyWith(fontSize: 32),
                ),
                if (activeCategory != null) ...[
                  const SizedBox(width: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: activeCategory.color.withAlpha(50),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: activeCategory.color),
                    ),
                    child: Row(
                      children: [
                        Icon(activeCategory.icon, color: activeCategory.color, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          activeCategory.name,
                          style: TextStyle(
                            color: activeCategory.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (activeCategory.requiresLogin) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.lock_rounded, size: 14, color: AppColors.secondary),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 18),

            // Horizontal Categories Selector
            if (categories.isNotEmpty)
              SizedBox(
                height: 56,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = cat.id == activeCategory?.id;
                    return CategoryChip(
                      category: cat,
                      isSelected: isSelected,
                      isDark: true,
                      onTap: () {
                        accessControl.guardCategory(
                          context,
                          categoryName: cat.name,
                          requiresLogin: cat.requiresLogin,
                          onAllowed: () {
                            setState(() => _selectedCategoryId = cat.id);
                          },
                        );
                      },
                    );
                  },
                ),
              ),

            const SizedBox(height: 24),

            // Videos Grid or Locked State
            Expanded(
              child: isCategoryLocked
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withAlpha(40),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.lock_rounded, size: 64, color: AppColors.secondary),
                          ),
                          const SizedBox(height: 20),
                          Text('Member Account Required', style: AppTypography.tvHeadline),
                          const SizedBox(height: 10),
                          Text(
                            'The category "${activeCategory.name}" requires user authentication.\nSign in or create a free account to watch all videos in this category.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70, fontSize: 18),
                          ),
                          const SizedBox(height: 24),
                          KidsButton(
                            autofocus: true,
                            label: 'Sign In / Register',
                            icon: Icons.login_rounded,
                            isDark: true,
                            onPressed: () => context.push('/user-login'),
                          ),
                        ],
                      ),
                    )
                  : videos.isEmpty
                      ? Center(
                          child: ErrorStateWidget(
                            title: 'No videos found in this category',
                            message: 'Check back soon for exciting new shows!',
                            isDark: true,
                          ),
                        )
                      : GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 0.88,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                          itemCount: videos.length,
                          itemBuilder: (context, index) {
                            final video = videos[index];
                            return VideoCard(
                              item: video,
                              width: double.infinity,
                              isDark: true,
                              onTap: () => context.push('/tv-video/${video.id}'),
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
