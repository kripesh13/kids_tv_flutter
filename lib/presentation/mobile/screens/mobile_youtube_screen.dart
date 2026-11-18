import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/content_provider.dart';
import '../../providers/youtube_provider.dart';
import '../../shared/widgets/channel_card.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/video_card.dart';

class MobileYoutubeScreen extends ConsumerWidget {
  const MobileYoutubeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final youtubeAsync = ref.watch(youtubeChannelsProvider);
    final contentState = ref.watch(contentProvider);

    final youtubeVideos = contentState.visibleItems.where((i) => i.isYouTube).toList();
    final allDisplayVideos = youtubeVideos.isNotEmpty
        ? youtubeVideos
        : contentState.visibleItems.take(6).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.smart_display_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text('YouTube Superstars', style: AppTypography.displayMedium),
                  ],
                ),
              ),
            ),

            // Channels Row
            SliverToBoxAdapter(
              child: youtubeAsync.when(
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
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Video Listings
            const SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Featured Videos',
                emoji: '🌟',
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.82,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final video = allDisplayVideos[index];
                    return VideoCard(
                      item: video,
                      width: double.infinity,
                      onTap: () => context.push('/video/${video.id}'),
                    );
                  },
                  childCount: allDisplayVideos.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }
}
