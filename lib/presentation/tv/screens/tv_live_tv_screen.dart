import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/tv/tv_focusable.dart';
import '../../providers/live_tv_provider.dart';
import '../../shared/player/universal_video_player.dart';
import '../../shared/widgets/kids_button.dart';

class TvLiveTvScreen extends ConsumerWidget {
  const TvLiveTvScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveTvState = ref.watch(liveTvProvider);
    final selectedChannel = liveTvState.selectedChannel;

    return Scaffold(
      backgroundColor: AppColors.tvBackground,
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  '24/7 Live Kids TV',
                  style: AppTypography.tvDisplay.copyWith(fontSize: 32),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'BROADCAST CHANNELS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Two Pane Layout (Player on Left, Channel Guide on Right)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Pane: Live Stream Preview Player
                  Expanded(
                    flex: 6,
                    child: selectedChannel != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  height: 380,
                                  color: Colors.black,
                                  child: UniversalVideoPlayer(
                                    key: ValueKey(selectedChannel.id),
                                    videoUrl: selectedChannel.streamUrl,
                                    title: selectedChannel.name,
                                    isLive: true,
                                    isTv: true,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selectedChannel.name,
                                        style: AppTypography.tvHeadline,
                                      ),
                                      if (selectedChannel.currentProgram != null)
                                        Text(
                                          'Playing: ${selectedChannel.currentProgram}',
                                          style: AppTypography.tvBody,
                                        ),
                                    ],
                                  ),
                                  KidsButton(
                                    label: 'Full Screen',
                                    icon: Icons.fullscreen_rounded,
                                    isDark: true,
                                    width: 160,
                                    onPressed: () {
                                      context.push('/tv-player/live_${selectedChannel.id}');
                                    },
                                  ),
                                ],
                              ),
                            ],
                          )
                        : const Center(
                            child: Text(
                              'No channel selected',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                  ),

                  const SizedBox(width: 24),

                  // Right Pane: Channel Guide List
                  Expanded(
                    flex: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.tvSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.tvCard),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Channel Guide', style: AppTypography.tvHeadline.copyWith(fontSize: 22)),
                          const SizedBox(height: 12),
                          Expanded(
                            child: ListView.separated(
                              physics: const BouncingScrollPhysics(),
                              itemCount: liveTvState.activeChannels.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final channel = liveTvState.activeChannels[index];
                                final isSelected = channel.id == selectedChannel?.id;
                                return TvFocusable(
                                  onPressed: () {
                                    ref.read(liveTvProvider.notifier).selectChannel(channel);
                                  },
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.tvCardHover : AppColors.tvCard,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isSelected ? AppColors.secondary : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Text(
                                              channel.channelNumber ?? '${index + 1}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                channel.name,
                                                style: AppTypography.tvTitle.copyWith(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (channel.currentProgram != null)
                                                Text(
                                                  channel.currentProgram!,
                                                  style: const TextStyle(
                                                    color: AppColors.tvTextSecondary,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        if (isSelected)
                                          const Icon(Icons.volume_up_rounded, color: AppColors.secondary, size: 20),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
