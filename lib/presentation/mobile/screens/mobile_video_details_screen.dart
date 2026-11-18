import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/enums/app_feature.dart';
import '../../providers/access_control_provider.dart';
import '../../providers/categories_provider.dart';
import '../../providers/content_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/likes_provider.dart';
import '../../shared/widgets/kids_button.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/video_card.dart';

class MobileVideoDetailsScreen extends ConsumerStatefulWidget {
  final String videoId;
  const MobileVideoDetailsScreen({super.key, required this.videoId});

  @override
  ConsumerState<MobileVideoDetailsScreen> createState() => _MobileVideoDetailsScreenState();
}

class _MobileVideoDetailsScreenState extends ConsumerState<MobileVideoDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(likesProvider.notifier).fetchLikesCount(widget.videoId);
    });
  }

  void _handleShare(String title, String id, bool allowSharing) {
    if (!allowSharing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sharing is currently disabled for this content.')),
      );
      return;
    }
    SharePlus.instance.share(
      ShareParams(
        text: 'Check out "$title" on Kids TV!\nWatch here: https://kidstv.stream/video/$id',
        subject: title,
      ),
    );
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
        appBar: AppBar(title: const Text('Video Not Found')),
        body: const Center(child: Text('This video is not available.')),
      );
    }

    final category = categoriesState.categories.where((c) => c.id == item.categoryId).firstOrNull;

    // Check if category requires login and user is guest
    final categoryRestricted = category != null &&
        category.requiresLogin &&
        !accessControl.canAccessCategory(requiresLogin: true);

    if (categoryRestricted) {
      return Scaffold(
        appBar: AppBar(
          title: Text(category.name),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_rounded, size: 72, color: AppColors.secondary),
                const SizedBox(height: 18),
                Text('Login Required', style: AppTypography.displayMedium),
                const SizedBox(height: 10),
                Text(
                  'The category "${category.name}" requires a free member account.\nSign in or register to stream this video.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 24),
                KidsButton(
                  label: 'Sign In to Watch',
                  icon: Icons.login_rounded,
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
        .take(6)
        .toList();

    final canShare = accessControl.canUseFeature(AppFeature.shareVideos) &&
        (category?.allowSharing ?? true);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Hero Video Thumbnail / Header
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: item.thumbnailUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(color: AppColors.primary),
                    errorWidget: (_, _, _) => Container(color: Colors.grey.shade400),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withAlpha(120),
                          Colors.transparent,
                          Colors.black.withAlpha(180),
                        ],
                      ),
                    ),
                  ),

                  // Big Center Play Button
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        ref.read(contentProvider.notifier).incrementViews(item.id);
                        context.push('/player/${item.id}');
                      },
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withAlpha(140),
                              blurRadius: 18,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 46,
                        ),
                      ),
                    ),
                  ),

                  // Duration or LIVE Badge
                  if (item.formattedDuration.isNotEmpty)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: item.isLive ? AppColors.error : Colors.black87,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.formattedDuration,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Content Information Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Pill & Views count
                  Row(
                    children: [
                      if (category != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: category.color.withAlpha(30),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: category.color.withAlpha(80)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(category.icon, size: 14, color: category.color),
                              const SizedBox(width: 6),
                              Text(
                                category.name,
                                style: TextStyle(
                                  color: category.color,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const Spacer(),
                      Icon(Icons.visibility_outlined, size: 16, color: AppColors.textLight),
                      const SizedBox(width: 4),
                      Text(
                        '${item.viewsCount} views',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    item.title,
                    style: AppTypography.displayMedium,
                  ),
                  const SizedBox(height: 14),

                  // Watch Now Big Button
                  KidsButton(
                    label: 'Watch Now',
                    icon: Icons.play_arrow_rounded,
                    width: double.infinity,
                    height: 52,
                    onPressed: () {
                      ref.read(contentProvider.notifier).incrementViews(item.id);
                      context.push('/player/${item.id}');
                    },
                  ),
                  const SizedBox(height: 16),

                  // Social / Interactive Action Bar (Like, Favorite, Share)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Like Button
                        TextButton.icon(
                          onPressed: () {
                            accessControl.guardFeature(
                              context,
                              feature: AppFeature.likes,
                              customTitle: 'Sign in to Like Videos',
                              customDescription:
                                  'Give a thumbs up to your favorite videos by signing in or creating a free account.',
                              onAllowed: () {
                                ref.read(likesProvider.notifier).toggleLike(item.id);
                              },
                            );
                          },
                          icon: Icon(
                            isLiked ? Icons.thumb_up_alt_rounded : Icons.thumb_up_alt_outlined,
                            color: isLiked ? AppColors.primary : AppColors.textSecondary,
                            size: 20,
                          ),
                          label: Text(
                            likesCount > 0 ? '$likesCount' : 'Like',
                            style: TextStyle(
                              color: isLiked ? AppColors.primary : AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // Favorite Button
                        TextButton.icon(
                          onPressed: () {
                            accessControl.guardFeature(
                              context,
                              feature: AppFeature.favorites,
                              customTitle: 'Sign in to Save Favorites',
                              customDescription:
                                  'Keep this video saved in your favorites list by signing in to your account.',
                              onAllowed: () {
                                ref.read(favoritesProvider.notifier).toggleFavorite(item);
                              },
                            );
                          },
                          icon: Icon(
                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFav ? AppColors.accent : AppColors.textSecondary,
                            size: 22,
                          ),
                          label: Text(
                            isFav ? 'Favorited' : 'Favorite',
                            style: TextStyle(
                              color: isFav ? AppColors.accent : AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // Share Button
                        TextButton.icon(
                          onPressed: () => _handleShare(item.title, item.id, canShare),
                          icon: const Icon(Icons.share_rounded, color: AppColors.textSecondary, size: 20),
                          label: const Text(
                            'Share',
                            style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  if (item.description != null && item.description!.isNotEmpty) ...[
                    Text(
                      'About this video',
                      style: AppTypography.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.description!,
                      style: AppTypography.bodyLarge.copyWith(height: 1.5),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Tags
                  if (item.tags.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: item.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primary.withAlpha(30)),
                          ),
                          child: Text(
                            '#$tag',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 24),

                  // Related Videos Section
                  if (relatedVideos.isNotEmpty) ...[
                    const SectionHeader(
                      title: 'More Like This',
                      emoji: '🎉',
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 210,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: relatedVideos.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          final rel = relatedVideos[index];
                          return VideoCard(
                            item: rel,
                            width: 220,
                            onTap: () => context.pushReplacement('/video/${rel.id}'),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
