import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/content_provider.dart';
import '../../providers/live_tv_provider.dart';
import '../../providers/watch_history_provider.dart';
import '../../shared/player/universal_video_player.dart';

class TvVideoPlayerScreen extends ConsumerWidget {
  final String videoId;
  const TvVideoPlayerScreen({super.key, required this.videoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLive = videoId.startsWith('live_');

    if (isLive) {
      final channelId = videoId.replaceFirst('live_', '');
      final liveTvState = ref.watch(liveTvProvider);
      final channel = liveTvState.channels.where((c) => c.id == channelId).firstOrNull ??
          liveTvState.selectedChannel;

      if (channel == null) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Channel not found', style: TextStyle(color: Colors.white)),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: () => context.pop(), child: const Text('Back')),
              ],
            ),
          ),
        );
      }

      return Scaffold(
        backgroundColor: Colors.black,
        body: UniversalVideoPlayer(
          key: ValueKey(channel.id),
          videoUrl: channel.streamUrl,
          fallbackUrl: channel.webStreamUrl,
          title: channel.name,
          isLive: true,
          isTv: true,
          onBack: () => context.pop(),
          onNextVideo: () {
            ref.read(liveTvProvider.notifier).selectNextChannel();
            final nextCh = ref.read(liveTvProvider).selectedChannel;
            if (nextCh != null) {
              context.pushReplacement('/tv-player/live_${nextCh.id}');
            }
          },
          onPreviousVideo: () {
            ref.read(liveTvProvider.notifier).selectPreviousChannel();
            final prevCh = ref.read(liveTvProvider).selectedChannel;
            if (prevCh != null) {
              context.pushReplacement('/tv-player/live_${prevCh.id}');
            }
          },
        ),
      );
    }

    // Standard content video
    final contentState = ref.watch(contentProvider);
    final item = contentState.visibleItems.where((i) => i.id == videoId).firstOrNull;

    if (item == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Video not found', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => context.pop(), child: const Text('Back')),
            ],
          ),
        ),
      );
    }

    final categoryVideos = contentState.itemsForCategory(item.categoryId ?? '');
    final currentIndex = categoryVideos.indexWhere((i) => i.id == item.id);
    final nextItem = (currentIndex != -1 && currentIndex + 1 < categoryVideos.length)
        ? categoryVideos[currentIndex + 1]
        : null;
    final prevItem = (currentIndex > 0) ? categoryVideos[currentIndex - 1] : null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: UniversalVideoPlayer(
        videoUrl: item.sourceUrl,
        title: item.title,
        isLive: item.isLive,
        isTv: true,
        onBack: () => context.pop(),
        onProgressUpdate: (pos, total) {
          ref.read(watchHistoryProvider.notifier).updateProgress(
                contentId: item.id,
                positionSeconds: pos,
                totalDurationSeconds: total,
              );
        },
        onNextVideo: nextItem != null
            ? () {
                ref.read(contentProvider.notifier).incrementViews(nextItem.id);
                context.pushReplacement('/tv-player/${nextItem.id}');
              }
            : null,
        onPreviousVideo: prevItem != null
            ? () {
                ref.read(contentProvider.notifier).incrementViews(prevItem.id);
                context.pushReplacement('/tv-player/${prevItem.id}');
              }
            : null,
      ),
    );
  }
}
