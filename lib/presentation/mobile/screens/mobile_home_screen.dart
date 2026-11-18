import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/access_control_provider.dart';
import '../../providers/banners_provider.dart';
import '../../providers/categories_provider.dart';
import '../../providers/content_provider.dart';
import '../../providers/live_tv_provider.dart';
import '../../providers/watch_history_provider.dart';
import '../../providers/youtube_provider.dart';
import '../../shared/widgets/banner_carousel.dart';
import '../../shared/widgets/category_chip.dart';
import '../../shared/widgets/channel_card.dart';
import '../../shared/widgets/kids_header.dart';
import '../../shared/widgets/live_channel_card.dart';
import '../../shared/widgets/loading_skeleton.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/video_card.dart';

class MobileHomeScreen extends ConsumerWidget {
  const MobileHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(categoriesProvider);
    final contentState = ref.watch(contentProvider);
    final bannersAsync = ref.watch(bannersProvider);
    final liveTvState = ref.watch(liveTvProvider);
    final youtubeAsync = ref.watch(youtubeChannelsProvider);
    final watchHistoryState = ref.watch(watchHistoryProvider);
    final accessControl = ref.watch(accessControlProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.read(categoriesProvider.notifier).loadCategories();
            ref.read(contentProvider.notifier).loadContent();
            ref.read(bannersProvider.notifier).loadBanners();
            ref.read(liveTvProvider.notifier).loadChannels();
            ref.read(watchHistoryProvider.notifier).loadHistory();
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: KidsHeader(
                  onSearchTap: () => context.push('/search'),
                ),
              ),

              // Banners Carousel
              SliverToBoxAdapter(
                child: bannersAsync.when(
                  data: (banners) => BannerCarousel(
                    banners: banners,
                    onBannerTap: (banner) {
                      if (banner.actionType.value == 'content') {
                        context.push('/video/${banner.actionTarget}');
                      } else if (banner.actionType.value == 'category') {
                        final cat = categoriesState.categories
                            .where((c) => c.id == banner.actionTarget || c.slug == banner.actionTarget)
                            .firstOrNull;
                        if (cat != null) {
                          accessControl.guardCategory(
                            context,
                            categoryName: cat.name,
                            requiresLogin: cat.requiresLogin,
                            onAllowed: () => context.push('/category/${cat.id}'),
                          );
                        } else {
                          context.push('/category/${banner.actionTarget}');
                        }
                      }
                    },
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: LoadingSkeleton(width: double.infinity, height: 180),
                  ),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Browse Categories Horizontal List
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: 'Explore Categories',
                      emoji: '🎈',
                      onSeeAll: () => context.push('/categories'),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 52,
                      child: categoriesState.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              scrollDirection: Axis.horizontal,
                              itemCount: categoriesState.visibleCategories.length,
                              separatorBuilder: (_, _) => const SizedBox(width: 10),
                              itemBuilder: (context, index) {
                                final cat = categoriesState.visibleCategories[index];
                                return CategoryChip(
                                  category: cat,
                                  compact: true,
                                  onTap: () {
                                    accessControl.guardCategory(
                                      context,
                                      categoryName: cat.name,
                                      requiresLogin: cat.requiresLogin,
                                      onAllowed: () => context.push('/category/${cat.id}'),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 18)),

              // Continue Watching Row (for authenticated users with progress)
              if (watchHistoryState.continueWatching.isNotEmpty)
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        title: 'Continue Watching',
                        emoji: '▶️',
                        onSeeAll: () => context.push('/history'),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: watchHistoryState.continueWatching.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 14),
                          itemBuilder: (context, index) {
                            final h = watchHistoryState.continueWatching[index];
                            final item = h.contentItem;
                            if (item == null) return const SizedBox.shrink();

                            return VideoCard(
                              item: item,
                              width: 220,
                              onTap: () => context.push('/player/${item.id}'),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),

              // Popular Videos Section
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(
                      title: 'Popular Videos',
                      emoji: '🔥',
                    ),
                    const SizedBox(height: 8),
                    contentState.isLoading
                        ? const VideoCardsRowSkeleton()
                        : SizedBox(
                            height: 200,
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              scrollDirection: Axis.horizontal,
                              itemCount: contentState.popularItems.length,
                              separatorBuilder: (_, _) => const SizedBox(width: 14),
                              itemBuilder: (context, index) {
                                final item = contentState.popularItems[index];
                                return VideoCard(
                                  item: item,
                                  width: 220,
                                  onTap: () => context.push('/video/${item.id}'),
                                );
                              },
                            ),
                          ),
                  ],
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // Kids Rhymes Spotlight Section
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: 'Nursery Rhymes',
                      emoji: '🎵',
                      onSeeAll: () {
                        final rhymesCat = categoriesState.categories
                            .where((c) => c.slug == 'rhymes')
                            .firstOrNull;
                        if (rhymesCat != null) {
                          accessControl.guardCategory(
                            context,
                            categoryName: rhymesCat.name,
                            requiresLogin: rhymesCat.requiresLogin,
                            onAllowed: () => context.push('/category/${rhymesCat.id}'),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: contentState.rhymesItems.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          final item = contentState.rhymesItems[index];
                          return VideoCard(
                            item: item,
                            width: 220,
                            onTap: () => context.push('/video/${item.id}'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // Live TV Preview Carousel
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: 'Live TV Channels',
                      emoji: '📺',
                      onSeeAll: () => context.push('/live-tv'),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 155,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: liveTvState.channels.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final channel = liveTvState.channels[index];
                          return LiveChannelCard(
                            channel: channel,
                            width: 160,
                            onTap: () {
                              ref.read(liveTvProvider.notifier).selectChannel(channel);
                              context.push('/live-tv');
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // Top Cartoons Section
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: 'Popular Cartoons',
                      emoji: '🐰',
                      onSeeAll: () {
                        final cat = categoriesState.categories
                            .where((c) => c.slug == 'cartoons')
                            .firstOrNull;
                        if (cat != null) {
                          accessControl.guardCategory(
                            context,
                            categoryName: cat.name,
                            requiresLogin: cat.requiresLogin,
                            onAllowed: () => context.push('/category/${cat.id}'),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: contentState.cartoonItems.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          final item = contentState.cartoonItems[index];
                          return VideoCard(
                            item: item,
                            width: 220,
                            onTap: () => context.push('/video/${item.id}'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // YouTube Superstars
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: 'YouTube Superstars',
                      emoji: '⭐',
                      onSeeAll: () => context.push('/youtube'),
                    ),
                    const SizedBox(height: 8),
                    youtubeAsync.when(
                      data: (channels) => SizedBox(
                        height: 155,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: channels.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final channel = channels[index];
                            return ChannelCard(channel: channel);
                          },
                        ),
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}
