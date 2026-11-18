import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/tv/tv_focusable.dart';
import '../../../domain/enums/app_feature.dart';
import '../../providers/access_control_provider.dart';
import '../../providers/categories_provider.dart';
import '../../providers/content_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/likes_provider.dart';
import '../../shared/widgets/kids_button.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/video_card.dart';

class TvVideoDetailsScreen extends ConsumerStatefulWidget {
  final String videoId;
  const TvVideoDetailsScreen({super.key, required this.videoId});

  @override
  ConsumerState<TvVideoDetailsScreen> createState() => _TvVideoDetailsScreenState();
}

class _TvVideoDetailsScreenState extends ConsumerState<TvVideoDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(likesProvider.notifier).fetchLikesCount(widget.videoId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final contentState = ref.watch(contentProvider);
    final categoriesState = ref.watch(categoriesProvider);
    final accessControl = ref.watch(accessControlProvider);
    final isFav = ref.watch(favoritesProvider.select((s) => s.isFavorite(widget.videoId)));
    final isLiked = ref.watch(likesProvider.select((s) => s.isLiked(widget.videoId)));
    final likesCount = ref.watch(likesProvider.select((s) => s.getCount(widget.videoId)));

    final item = contentState.visibleItems.where((i) => i.id == widget.videoId).firstOrNull;

    if (item == null) {
      return Scaffold(
        backgroundColor: AppColors.tvBackground,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Video not found', style: AppTypography.tvHeadline),
              const SizedBox(height: 16),
              KidsButton(
                label: 'Back',
                isDark: true,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      );
    }

    final category = categoriesState.categories.where((c) => c.id == item.categoryId).firstOrNull;

    // Check if category requires login and user is guest
    final categoryRestricted = category != null &&
        category.requiresLogin &&
        !accessControl.canAccessCategory(requiresLogin: true);

    if (categoryRestricted) {
      return Scaffold(
        backgroundColor: AppColors.tvBackground,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_rounded, size: 72, color: AppColors.secondary),
                const SizedBox(height: 18),
                Text('Member Account Required', style: AppTypography.tvDisplay),
                const SizedBox(height: 10),
                Text(
                  'The category "${category.name}" requires user authentication.\nPlease sign in to watch this title.',
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
          ),
        ),
      );
    }

    final relatedVideos = contentState.visibleItems
        .where((i) => i.id != item.id && (i.categoryId == item.categoryId || i.isFeatured))
        .take(8)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.tvBackground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Backdrop Image
          CachedNetworkImage(
            imageUrl: item.thumbnailUrl,
            fit: BoxFit.cover,
            placeholder: (_, _) => Container(color: AppColors.tvBackground),
            errorWidget: (_, _, _) => Container(color: AppColors.tvBackground),
          ),

          // Cinematic Radial and Linear Vignette
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withAlpha(200),
                  Colors.black.withAlpha(235),
                  AppColors.tvBackground,
                ],
                stops: const [0.0, 0.45, 0.95],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withAlpha(240),
                  Colors.black.withAlpha(160),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),

          // Main Scrollable Details & Related Row
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  TvFocusable(
                    onPressed: () => context.pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.tvCard,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text('Back', style: TextStyle(color: Colors.white, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Category & Duration Badges
                  Row(
                    children: [
                      if (category != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: category.color.withAlpha(60),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: category.color),
                          ),
                          child: Text(
                            category.name,
                            style: TextStyle(
                              color: category.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      if (item.formattedDuration.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.formattedDuration,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          const Icon(Icons.visibility_outlined, size: 16, color: Colors.white60),
                          const SizedBox(width: 6),
                          Text(
                            '${item.viewsCount} views',
                            style: const TextStyle(color: Colors.white60, fontSize: 14),
                          ),
                        ],
                      ),
                      if (likesCount > 0) ...[
                        const SizedBox(width: 14),
                        Row(
                          children: [
                            const Icon(Icons.thumb_up_alt_rounded, size: 16, color: AppColors.secondary),
                            const SizedBox(width: 6),
                            Text(
                              '$likesCount likes',
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Title
                  SizedBox(
                    width: 700,
                    child: Text(
                      item.title,
                      style: AppTypography.tvDisplay.copyWith(color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Description
                  if (item.description != null)
                    SizedBox(
                      width: 650,
                      child: Text(
                        item.description!,
                        style: AppTypography.tvBody.copyWith(fontSize: 18, height: 1.5),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Action Buttons Row (Watch Now, Favorite, Like, Share)
                  Row(
                    children: [
                      KidsButton(
                        autofocus: true,
                        label: 'Watch Now',
                        icon: Icons.play_arrow_rounded,
                        isDark: true,
                        width: 180,
                        height: 54,
                        onPressed: () {
                          ref.read(contentProvider.notifier).incrementViews(item.id);
                          context.push('/tv-player/${item.id}');
                        },
                      ),
                      const SizedBox(width: 14),

                      // Favorite Button
                      KidsButton(
                        label: isFav ? 'Favorited' : 'Favorite',
                        icon: isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        variant: isFav ? KidsButtonVariant.primary : KidsButtonVariant.outline,
                        isDark: true,
                        height: 54,
                        onPressed: () {
                          accessControl.guardFeature(
                            context,
                            feature: AppFeature.favorites,
                            customTitle: 'Sign in to Save Favorites',
                            onAllowed: () {
                              ref.read(favoritesProvider.notifier).toggleFavorite(item);
                            },
                          );
                        },
                      ),
                      const SizedBox(width: 14),

                      // Like Button
                      KidsButton(
                        label: isLiked ? 'Liked ($likesCount)' : 'Like ($likesCount)',
                        icon: isLiked ? Icons.thumb_up_alt_rounded : Icons.thumb_up_alt_outlined,
                        variant: isLiked ? KidsButtonVariant.primary : KidsButtonVariant.outline,
                        isDark: true,
                        height: 54,
                        onPressed: () {
                          accessControl.guardFeature(
                            context,
                            feature: AppFeature.likes,
                            customTitle: 'Sign in to Like Videos',
                            onAllowed: () {
                              ref.read(likesProvider.notifier).toggleLike(item.id);
                            },
                          );
                        },
                      ),
                      const SizedBox(width: 14),

                      // Share Button
                      KidsButton(
                        label: 'Share',
                        icon: Icons.share_rounded,
                        variant: KidsButtonVariant.outline,
                        isDark: true,
                        height: 54,
                        onPressed: () {
                          SharePlus.instance.share(
                            ShareParams(
                              text: 'Check out "${item.title}" on Kids TV!\nWatch here: https://kidstv.stream/video/${item.id}',
                              subject: item.title,
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),

                  // Related Videos Row
                  if (relatedVideos.isNotEmpty) ...[
                    const SectionHeader(
                      title: 'Related Videos',
                      emoji: '✨',
                      isDark: true,
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 230,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: relatedVideos.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 20),
                        itemBuilder: (context, index) {
                          final rel = relatedVideos[index];
                          return VideoCard(
                            item: rel,
                            width: 260,
                            isDark: true,
                            onTap: () => context.pushReplacement('/tv-video/${rel.id}'),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
