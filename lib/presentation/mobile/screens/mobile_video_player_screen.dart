import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/content_provider.dart';
import '../../providers/watch_history_provider.dart';
import '../../shared/player/universal_video_player.dart';

class MobileVideoPlayerScreen extends ConsumerStatefulWidget {
  final String videoId;
  const MobileVideoPlayerScreen({super.key, required this.videoId});

  @override
  ConsumerState<MobileVideoPlayerScreen> createState() => _MobileVideoPlayerScreenState();
}

class _MobileVideoPlayerScreenState extends ConsumerState<MobileVideoPlayerScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contentState = ref.watch(contentProvider);
    final item = contentState.visibleItems.where((i) => i.id == widget.videoId).firstOrNull;

    if (item == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Video not found', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      );
    }

    // Determine next video in category
    final categoryVideos = contentState.itemsForCategory(item.categoryId ?? '');
    final currentIndex = categoryVideos.indexWhere((i) => i.id == item.id);
    final nextItem = (currentIndex != -1 && currentIndex + 1 < categoryVideos.length)
        ? categoryVideos[currentIndex + 1]
        : (contentState.visibleItems.firstOrNull != null && contentState.visibleItems.first.id != item.id
            ? contentState.visibleItems.first
            : null);

    return Scaffold(
      backgroundColor: Colors.black,
      body: UniversalVideoPlayer(
        videoUrl: item.sourceUrl,
        title: item.title,
        isLive: item.isLive,
        isTv: false,
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
                context.pushReplacement('/player/${nextItem.id}');
              }
            : null,
      ),
    );
  }
}
