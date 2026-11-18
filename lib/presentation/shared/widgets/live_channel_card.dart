import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/tv/tv_focusable.dart';
import '../../../data/models/live_channel_model.dart';

class LiveChannelCard extends StatelessWidget {
  final LiveChannelModel channel;
  final bool isSelected;
  final VoidCallback? onTap;
  final double width;
  final bool isDark;
  final bool compact;

  const LiveChannelCard({
    super.key,
    required this.channel,
    this.isSelected = false,
    this.onTap,
    this.width = 180,
    this.isDark = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TvFocusable(
        onPressed: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withAlpha(isDark ? 80 : 35)
                : (isDark ? AppColors.tvCard : AppColors.cardBackground),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? (isDark ? AppColors.secondary : AppColors.primary)
                  : (isDark ? AppColors.tvCardHover : AppColors.primary.withAlpha(20)),
              width: isSelected ? 2.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? AppColors.primary.withAlpha(50)
                    : (isDark ? Colors.black38 : AppColors.primary.withAlpha(15)),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompactMode = compact ||
                  (constraints.hasBoundedHeight && constraints.maxHeight < 125);
              if (isCompactMode) {
                return _buildCompactLayout(context, constraints);
              }
              return _buildStandardLayout(context, constraints);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCompactLayout(BuildContext context, BoxConstraints constraints) {
    return Row(
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 50,
                height: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: channel.logoUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.primary.withAlpha(30),
                    child: const Center(
                      child: Icon(Icons.live_tv, color: AppColors.primary, size: 20),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(Icons.live_tv, color: Colors.grey, size: 20),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 3,
              left: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: Colors.white, size: 4),
                    SizedBox(width: 2),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 7.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                channel.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: (isDark ? AppTypography.tvTitle : AppTypography.titleLarge).copyWith(
                  fontSize: isDark ? 13 : 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.tvText : AppColors.text,
                ),
              ),
              if (channel.currentProgram != null) ...[
                const SizedBox(height: 2),
                Text(
                  channel.currentProgram!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? AppColors.tvTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStandardLayout(BuildContext context, BoxConstraints constraints) {
    final availableH = constraints.hasBoundedHeight ? constraints.maxHeight : 150.0;
    final logoH = (availableH - 48).clamp(44.0, 95.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo and Live Badge Row
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: logoH,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: channel.logoUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.primary.withAlpha(30),
                    child: const Center(
                      child: Icon(Icons.live_tv, color: AppColors.primary),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(Icons.live_tv, color: Colors.grey),
                    ),
                  ),
                ),

                // LIVE blinking pill
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Channel Number Badge
                if (channel.channelNumber != null)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'CH ${channel.channelNumber}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),

        // Channel Name
        Text(
          channel.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: (isDark ? AppTypography.tvTitle : AppTypography.titleLarge).copyWith(
            fontSize: isDark ? 14 : 13,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.tvText : AppColors.text,
          ),
        ),

        // Current Program
        if (channel.currentProgram != null) ...[
          const SizedBox(height: 2),
          Text(
            channel.currentProgram!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.tvTextSecondary : AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
