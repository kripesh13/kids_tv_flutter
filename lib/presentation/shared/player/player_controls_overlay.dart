import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/duration_formatter.dart';

class PlayerControlsOverlay extends StatelessWidget {
  final VideoPlayerController controller;
  final String title;
  final bool isLive;
  final VoidCallback onPlayPause;
  final ValueChanged<Duration> onSeekBy;
  final ValueChanged<Duration> onSeekTo;
  final VoidCallback? onNext;
  final VoidCallback? onBack;

  const PlayerControlsOverlay({
    super.key,
    required this.controller,
    required this.title,
    required this.isLive,
    required this.onPlayPause,
    required this.onSeekBy,
    required this.onSeekTo,
    this.onNext,
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
            Colors.black.withAlpha(160),
            Colors.transparent,
            Colors.black.withAlpha(190),
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  if (onBack != null)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 22),
                      onPressed: onBack,
                    ),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (isLive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
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
                ],
              ),
            ),

            // Center Play/Pause & 10s Seek Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isLive) ...[
                  IconButton(
                    iconSize: 44,
                    icon: const Icon(Icons.replay_10_rounded,
                        color: Colors.white),
                    onPressed: () => onSeekBy(const Duration(seconds: -10)),
                  ),
                  const SizedBox(width: 24),
                ],
                GestureDetector(
                  onTap: onPlayPause,
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(120),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (!isLive) ...[
                  const SizedBox(width: 24),
                  IconButton(
                    iconSize: 44,
                    icon: const Icon(Icons.forward_10_rounded,
                        color: Colors.white),
                    onPressed: () => onSeekBy(const Duration(seconds: 10)),
                  ),
                ],
                if (onNext != null) ...[
                  const SizedBox(width: 16),
                  IconButton(
                    iconSize: 36,
                    icon: const Icon(Icons.skip_next_rounded,
                        color: Colors.white),
                    onPressed: onNext,
                  ),
                ],
              ],
            ),

            // Bottom Progress & Duration
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: isLive
                  ? const SizedBox.shrink()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 8),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 16),
                            activeTrackColor: AppColors.secondary,
                            inactiveTrackColor: Colors.white24,
                            thumbColor: AppColors.secondary,
                          ),
                          child: Slider(
                            value: position.inMilliseconds.toDouble().clamp(
                                0.0, duration.inMilliseconds.toDouble()),
                            min: 0.0,
                            max: duration.inMilliseconds.toDouble() > 0
                                ? duration.inMilliseconds.toDouble()
                                : 1.0,
                            onChanged: (val) {
                              onSeekTo(Duration(milliseconds: val.toInt()));
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DurationFormatter.format(position),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                DurationFormatter.format(duration),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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
