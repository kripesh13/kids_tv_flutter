import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/tv/tv_focusable.dart';
import '../../../data/models/youtube_channel_model.dart';

class ChannelCard extends StatelessWidget {
  final YoutubeChannelModel channel;
  final VoidCallback? onTap;
  final double width;
  final bool isDark;

  const ChannelCard({
    super.key,
    required this.channel,
    this.onTap,
    this.width = 160,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TvFocusable(
        onPressed: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.tvCard : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black38 : AppColors.primary.withAlpha(20),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: isDark ? AppColors.tvCardHover : AppColors.primary.withAlpha(15),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.secondary, width: 2.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: channel.thumbnailUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.primary.withAlpha(40),
                      child: const Icon(Icons.smart_display, color: AppColors.primary),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.person, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Title
              Text(
                channel.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: (isDark ? AppTypography.tvTitle : AppTypography.titleLarge).copyWith(
                  fontSize: isDark ? 14 : 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.tvText : AppColors.text,
                ),
              ),
              const SizedBox(height: 4),

              // Subscriber Count Badge
              if (channel.subscriberCount != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withAlpha(isDark ? 50 : 25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${channel.subscriberCount} Subs',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.accentLight : AppColors.accent,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
