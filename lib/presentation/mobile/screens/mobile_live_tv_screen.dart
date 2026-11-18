import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/live_tv_provider.dart';
import '../../shared/player/universal_video_player.dart';
import '../../shared/widgets/live_channel_card.dart';

class MobileLiveTvScreen extends ConsumerWidget {
  const MobileLiveTvScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveTvState = ref.watch(liveTvProvider);
    final selectedChannel = liveTvState.selectedChannel;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Live Stream Player
            if (selectedChannel != null)
              Container(
                height: 220,
                width: double.infinity,
                color: Colors.black,
                child: UniversalVideoPlayer(
                  key: ValueKey(selectedChannel.id),
                  videoUrl: selectedChannel.streamUrl,
                  fallbackUrl: selectedChannel.webStreamUrl,
                  title: selectedChannel.name,
                  isLive: true,
                  isTv: false,
                  onNextVideo: () {
                    ref.read(liveTvProvider.notifier).selectNextChannel();
                  },
                  onPreviousVideo: () {
                    ref.read(liveTvProvider.notifier).selectPreviousChannel();
                  },
                ),
              )
            else
              Container(
                height: 220,
                color: Colors.black87,
                child: const Center(
                  child: Text(
                    'No live channels currently active',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),

            // Channel Info Bar
            if (selectedChannel != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.white,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: Colors.white, size: 6),
                          SizedBox(width: 4),
                          Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedChannel.name,
                            style: AppTypography.headlineMedium,
                          ),
                          if (selectedChannel.currentProgram != null)
                            Text(
                              'Now: ${selectedChannel.currentProgram}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_previous_rounded, color: AppColors.primary),
                      onPressed: () {
                        ref.read(liveTvProvider.notifier).selectPreviousChannel();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next_rounded, color: AppColors.primary),
                      onPressed: () {
                        ref.read(liveTvProvider.notifier).selectNextChannel();
                      },
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            // Channel Guide Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: Text(
                'Live Channel Guide',
                style: AppTypography.displayMedium,
              ),
            ),

            // Channels List
            Expanded(
              child: liveTvState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.15,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: liveTvState.activeChannels.length,
                      itemBuilder: (context, index) {
                        final channel = liveTvState.activeChannels[index];
                        final isCurrent = channel.id == selectedChannel?.id;
                        return LiveChannelCard(
                          channel: channel,
                          isSelected: isCurrent,
                          width: double.infinity,
                          onTap: () {
                            ref.read(liveTvProvider.notifier).selectChannel(channel);
                          },
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
