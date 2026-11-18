import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/tv/tv_focusable.dart';
import '../../../data/models/content_item_model.dart';
import '../../../domain/enums/app_feature.dart';
import '../../providers/access_control_provider.dart';
import '../../providers/favorites_provider.dart';

class VideoCard extends ConsumerWidget {
  final ContentItemModel item;
  final VoidCallback? onTap;
  final double width;
  final double? height;
  final bool isDark;
  final bool showCategory;
  final String? categoryName;
  final Color? categoryColor;

  const VideoCard({
    super.key,
    required this.item,
    this.onTap,
    this.width = 240,
    this.height,
    this.isDark = false,
    this.showCategory = false,
    this.categoryName,
    this.categoryColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExplicitWidth = width.isFinite && width > 0;
    final cardHeight = height ?? (isExplicitWidth ? width * 0.92 : null);
    final isFav = ref.watch(favoritesProvider.select((s) => s.isFavorite(item.id)));
    final accessControl = ref.watch(accessControlProvider);

    Widget cardContent = TvFocusable(
      onPressed: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.tvCard : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black45 : AppColors.primary.withAlpha(25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with Overlays (16:9 AspectRatio)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: CachedNetworkImage(
                      imageUrl: item.thumbnailUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,
                        ),
                        child: const Center(
                          child: Icon(Icons.movie_outlined, color: Colors.white38, size: 36),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: isDark ? AppColors.tvSurface : AppColors.cardSecondary,
                        child: const Center(
                          child: Icon(Icons.broken_image_rounded, color: Colors.grey, size: 36),
                        ),
                      ),
                    ),
                  ),

                  // Dark subtle gradient overlay at bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withAlpha(160)],
                        ),
                      ),
                    ),
                  ),

                  // Play Button Circle Center Overlay
                  Center(
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(210),
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),

                  // Duration or LIVE Badge
                  if (item.formattedDuration.isNotEmpty)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: item.isLive ? AppColors.error : Colors.black87,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (item.isLive) ...[
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              item.formattedDuration,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Category Pill Overlay (if present)
                  if (showCategory && categoryName != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (categoryColor ?? AppColors.primary).withAlpha(220),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          categoryName!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                  // Favorite Button (Top Right Overlay)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        accessControl.guardFeature(
                          context,
                          feature: AppFeature.favorites,
                          customTitle: 'Sign in to Save Favorites',
                          customDescription:
                              'Create a free account or sign in to save "${item.title}" to your favorites.',
                          onAllowed: () {
                            ref.read(favoritesProvider.notifier).toggleFavorite(item);
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(120),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: isFav ? AppColors.accent : Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Title and Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: (isDark ? AppTypography.tvTitle : AppTypography.titleLarge).copyWith(
                          fontSize: isDark ? 15 : 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.tvText : AppColors.text,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.visibility_outlined,
                          size: 13,
                          color: isDark ? AppColors.tvTextSecondary : AppColors.textLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item.viewsCount} views',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.tvTextSecondary : AppColors.textLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (isExplicitWidth) {
      return SizedBox(
        width: width,
        height: cardHeight,
        child: cardContent,
      );
    }
    return cardContent;
  }
}
