import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/tv/tv_focusable.dart';
import '../../../core/utils/duration_formatter.dart';

class TvPlayerControls extends StatelessWidget {
  final VideoPlayerController controller;
  final String title;
  final bool isLive;
  final VoidCallback onPlayPause;
  final ValueChanged<Duration> onSeekBy;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final VoidCallback? onBack;

  const TvPlayerControls({
    super.key,
    required this.controller,
    required this.title,
    required this.isLive,
    required this.onPlayPause,
    required this.onSeekBy,
    this.onNext,
    this.onPrevious,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isPlaying = controller.value.isPlaying;
    final position = controller.value.position;
    final duration = controller.value.duration;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withAlpha(210),
            Colors.transparent,
            Colors.black.withAlpha(230),
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Title Bar & Back
          Row(
            children: [
              if (onBack != null)
                TvFocusable(
                  onPressed: onBack,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.tvCard,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back, color: Colors.white, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Back',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.tvHeadline.copyWith(color: Colors.white),
                ),
              ),
              if (isLive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, color: Colors.white, size: 8),
                      SizedBox(width: 6),
                      Text(
                        'LIVE STREAM',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // Center Remote Focusable Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (onPrevious != null) ...[
                TvFocusable(
                  onPressed: onPrevious,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(
                      color: AppColors.tvCard,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.skip_previous_rounded,
                        color: Colors.white, size: 30),
                  ),
                ),
                const SizedBox(width: 24),
              ],
              if (!isLive) ...[
                TvFocusable(
                  onPressed: () => onSeekBy(const Duration(seconds: -10)),
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(
                      color: AppColors.tvCard,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.replay_10_rounded,
                        color: Colors.white, size: 32),
                  ),
                ),
                const SizedBox(width: 24),
              ],

              // Play / Pause Button (Auto-focused by default)
              TvFocusable(
                autofocus: true,
                onPressed: onPlayPause,
                borderRadius: BorderRadius.circular(44),
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withAlpha(140),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: AppColors.text,
                    size: 52,
                  ),
                ),
              ),

              if (!isLive) ...[
                const SizedBox(width: 24),
                TvFocusable(
                  onPressed: () => onSeekBy(const Duration(seconds: 10)),
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(
                      color: AppColors.tvCard,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.forward_10_rounded,
                        color: Colors.white, size: 32),
                  ),
                ),
              ],
              if (onNext != null) ...[
                const SizedBox(width: 24),
                TvFocusable(
                  onPressed: onNext,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(
                      color: AppColors.tvCard,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.skip_next_rounded,
                        color: Colors.white, size: 30),
                  ),
                ),
              ],
            ],
          ),

          // Bottom Progress Bar
          if (!isLive)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: duration.inMilliseconds > 0
                        ? (position.inMilliseconds / duration.inMilliseconds)
                            .clamp(0.0, 1.0)
                        : 0.0,
                    minHeight: 8,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.secondary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DurationFormatter.format(position),
                      style: AppTypography.tvTitle.copyWith(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      DurationFormatter.format(duration),
                      style: AppTypography.tvTitle.copyWith(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}
