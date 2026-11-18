import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/access_control_provider.dart';
import '../../providers/banners_provider.dart';
import '../../providers/categories_provider.dart';
import '../../providers/content_provider.dart';
import '../../providers/live_tv_provider.dart';
import '../../providers/watch_history_provider.dart';
import '../../providers/youtube_provider.dart';
import '../../shared/widgets/category_chip.dart';
import '../../shared/widgets/channel_card.dart';
import '../../shared/widgets/kids_button.dart';
import '../../shared/widgets/live_channel_card.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/video_card.dart';

class TvHomeScreen extends ConsumerWidget {
  const TvHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannersAsync = ref.watch(bannersProvider);
    final categoriesState = ref.watch(categoriesProvider);
    final contentState = ref.watch(contentProvider);
    final liveTvState = ref.watch(liveTvProvider);
    final youtubeAsync = ref.watch(youtubeChannelsProvider);
    final watchHistoryState = ref.watch(watchHistoryProvider);
    final accessControl = ref.watch(accessControlProvider);

    final featuredItem = contentState.featuredItems.firstOrNull ??
        contentState.visibleItems.firstOrNull;

    return Scaffold(
      backgroundColor: AppColors.tvBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Hero Billboard Banner (Cinematic TV Spotlight)
          SliverToBoxAdapter(
            child: bannersAsync.when(
              data: (banners) {
                final banner = banners.firstOrNull;
                if (banner == null && featuredItem == null) {
                  return const SizedBox.shrink();
                }

                final title = banner?.title ?? featuredItem?.title ?? 'Kids TV';
                final subtitle = banner?.subtitle ?? featuredItem?.description ?? '';
                final bgUrl = banner?.imageUrl ?? featuredItem?.thumbnailUrl ?? '';
                final targetId = banner?.actionTarget ?? featuredItem?.id ?? '';

                return Container(
                  height: 380,
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(28, 20, 28, 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background image
                        CachedNetworkImage(
                          imageUrl: bgUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => Container(color: AppColors.tvCard),
                          errorWidget: (_, _, _) => Container(color: AppColors.tvCard),
                        ),

                        // Cinematic Dark Vignette Overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.black.withAlpha(240),
                                Colors.black.withAlpha(160),
                                Colors.black.withAlpha(20),
                              ],
                              stops: const [0.0, 0.55, 1.0],
                            ),
                          ),
                        ),

                        // Billboard Details
                        Positioned(
                          left: 40,
                          bottom: 40,
                          top: 40,
                          width: 480,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star_rounded, color: Colors.white, size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      'FEATURED SPOTLIGHT',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.tvDisplay,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                subtitle,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.tvBody,
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  KidsButton(
                                    autofocus: true,
                                    label: 'Watch Now',
                                    icon: Icons.play_arrow_rounded,
                                    isDark: true,
                                    width: 170,
                                    onPressed: () {
                                      if (banner != null && banner.actionType.value == 'category') {
                                        final cat = categoriesState.categories
                                            .where((c) => c.id == banner.actionTarget || c.slug == banner.actionTarget)
                                            .firstOrNull;
                                        if (cat != null) {
                                          accessControl.guardCategory(
                                            context,
                                            categoryName: cat.name,
                                            requiresLogin: cat.requiresLogin,
                                            onAllowed: () => context.push('/tv-category/${cat.id}'),
                                          );
                                        }
                                      } else if (targetId.isNotEmpty) {
                                        context.push('/tv-player/$targetId');
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 14),
                                  KidsButton(
                                    label: 'Details',
                                    icon: Icons.info_outline_rounded,
                                    variant: KidsButtonVariant.outline,
                                    isDark: true,
                                    width: 140,
                                    onPressed: () {
                                      if (targetId.isNotEmpty) {
                                        context.push('/tv-video/$targetId');
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => Container(
                height: 380,
                margin: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.tvCard,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ),

          // Categories Quick Focus Row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 12, 28, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: 'Categories',
                    emoji: '🎈',
                    isDark: true,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 58,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categoriesState.visibleCategories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final cat = categoriesState.visibleCategories[index];
                        return CategoryChip(
                          category: cat,
                          isDark: true,
                          onTap: () {
                            accessControl.guardCategory(
                              context,
                              categoryName: cat.name,
                              requiresLogin: cat.requiresLogin,
                              onAllowed: () => context.push('/tv-category/${cat.id}'),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Continue Watching Row (TV)
          if (watchHistoryState.continueWatching.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(
                      title: 'Continue Watching',
                      emoji: '▶️',
                      isDark: true,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 230,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: watchHistoryState.continueWatching.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 18),
                        itemBuilder: (context, index) {
                          final h = watchHistoryState.continueWatching[index];
                          final item = h.contentItem;
                          if (item == null) return const SizedBox.shrink();

                          return VideoCard(
                            item: item,
                            width: 260,
                            isDark: true,
                            onTap: () => context.push('/tv-player/${item.id}'),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),

          // Recommended Videos Row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: 'Recommended Videos',
                    emoji: '⭐',
                    isDark: true,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 230,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: contentState.featuredItems.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 18),
                      itemBuilder: (context, index) {
                        final item = contentState.featuredItems[index];
                        return VideoCard(
                          item: item,
                          width: 260,
                          isDark: true,
                          onTap: () => context.push('/tv-video/${item.id}'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // Popular Cartoons Row
          Builder(
            builder: (context) {
              final cartoonCat = categoriesState.categories.where(
                (c) => c.slug == 'cartoons' || c.name.toLowerCase() == 'cartoons',
              ).firstOrNull;

              final cartoons = cartoonCat != null
                  ? contentState.itemsForCategory(cartoonCat.id)
                  : contentState.popularItems;

              if (cartoons.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        title: 'Popular Cartoons',
                        emoji: '🐰',
                        isDark: true,
                        onSeeAll: cartoonCat != null
                            ? () {
                                accessControl.guardCategory(
                                  context,
                                  categoryName: cartoonCat.name,
                                  requiresLogin: cartoonCat.requiresLogin,
                                  onAllowed: () => context.push('/tv-category/${cartoonCat.id}'),
                                );
                              }
                            : null,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 230,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: cartoons.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 18),
                          itemBuilder: (context, index) {
                            final item = cartoons[index];
                            return VideoCard(
                              item: item,
                              width: 260,
                              isDark: true,
                              onTap: () => context.push('/tv-video/${item.id}'),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // Live TV Channels Carousel
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: 'Live TV Channels',
                    emoji: '📺',
                    isDark: true,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 165,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: liveTvState.channels.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final channel = liveTvState.channels[index];
                        return LiveChannelCard(
                          channel: channel,
                          isDark: true,
                          width: 200,
                          onTap: () {
                            ref.read(liveTvProvider.notifier).selectChannel(channel);
                            context.push('/tv-player/live_${channel.id}');
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // YouTube Superstars Row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: 'YouTube Channels',
                    emoji: '🔴',
                    isDark: true,
                  ),
                  const SizedBox(height: 10),
                  youtubeAsync.when(
                    data: (channels) => SizedBox(
                      height: 175,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: channels.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final channel = channels[index];
                          return ChannelCard(
                            channel: channel,
                            isDark: true,
                          );
                        },
                      ),
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 48)),
        ],
      ),
    );
  }
}
