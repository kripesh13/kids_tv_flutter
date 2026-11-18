import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/content_provider.dart';
import '../../providers/youtube_provider.dart';
import '../../shared/widgets/channel_card.dart';
import '../../shared/widgets/video_card.dart';

class TvYoutubeScreen extends ConsumerWidget {
  const TvYoutubeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final youtubeAsync = ref.watch(youtubeChannelsProvider);
    final contentState = ref.watch(contentProvider);

    final youtubeVideos = contentState.visibleItems.where((i) => i.isYouTube).toList();
    final allDisplayVideos = youtubeVideos.isNotEmpty
        ? youtubeVideos
        : contentState.visibleItems.take(8).toList();

    return Scaffold(
      backgroundColor: AppColors.tvBackground,
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.smart_display_rounded, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'YouTube Superstars',
                    style: AppTypography.tvDisplay.copyWith(fontSize: 32),
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Channels Row
            SliverToBoxAdapter(
              child: youtubeAsync.when(
                data: (channels) => SizedBox(
                  height: 165,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: channels.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final ch = channels[index];
                      return ChannelCard(
                        channel: ch,
                        width: 180,
                        isDark: true,
                      );
                    },
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            SliverToBoxAdapter(
              child: Text(
                'Featured Episodes',
                style: AppTypography.tvHeadline.copyWith(fontSize: 24),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.88,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final video = allDisplayVideos[index];
                  return VideoCard(
                    item: video,
                    width: double.infinity,
                    isDark: true,
                    onTap: () => context.push('/tv-video/${video.id}'),
                  );
                },
                childCount: allDisplayVideos.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
