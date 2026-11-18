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

class MobileCategoryScreen extends ConsumerStatefulWidget {
  final String? initialCategoryId;
  const MobileCategoryScreen({super.key, this.initialCategoryId});

  @override
  ConsumerState<MobileCategoryScreen> createState() => _MobileCategoryScreenState();
}

class _MobileCategoryScreenState extends ConsumerState<MobileCategoryScreen> {
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
  }

  @override
  void didUpdateWidget(covariant MobileCategoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategoryId != oldWidget.initialCategoryId) {
      _selectedCategoryId = widget.initialCategoryId;
    }
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/');
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Categories',
                    style: AppTypography.displayMedium,
                  ),
                ],
              ),
            ),

            // Horizontal Categories Selector Bar
            if (categories.isNotEmpty)
              SizedBox(
                height: 52,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = cat.id == activeCategory?.id;
                    return CategoryChip(
                      category: cat,
                      isSelected: isSelected,
                      compact: true,
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

            const SizedBox(height: 12),

            // Category Banner Card
            if (activeCategory != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        activeCategory.color,
                        activeCategory.color.withAlpha(200),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: activeCategory.color.withAlpha(60),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(50),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          activeCategory.requiresLogin ? Icons.lock_rounded : activeCategory.icon,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  activeCategory.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                if (activeCategory.requiresLogin) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black38,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'MEMBER ONLY',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (activeCategory.description != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                activeCategory.description!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 14),

            // Videos Grid or Locked State
            Expanded(
              child: isCategoryLocked
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withAlpha(40),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.lock_rounded,
                                size: 54,
                                color: Colors.deepOrange,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Sign in to access ${activeCategory.name}',
                              style: AppTypography.displayMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'This category is reserved for Kids TV members.\nCreate a free account or sign in to watch all videos in this category.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                            ),
                            const SizedBox(height: 24),
                            KidsButton(
                              label: 'Sign In to Unlock',
                              icon: Icons.login_rounded,
                              onPressed: () => context.push('/user-login'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : contentState.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : videos.isEmpty
                          ? const Center(
                              child: ErrorStateWidget(
                                title: 'No Videos Yet',
                                message: 'Check back soon for exciting new cartoons in this category!',
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
                              itemCount: videos.length,
                              itemBuilder: (context, index) {
                                final item = videos[index];
                                return VideoCard(
                                  item: item,
                                  width: double.infinity,
                                  onTap: () => context.push('/video/${item.id}'),
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
