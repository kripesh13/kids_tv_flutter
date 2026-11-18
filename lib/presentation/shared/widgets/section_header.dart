import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/tv/tv_focusable.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? emoji;
  final VoidCallback? onSeeAll;
  final bool isDark;

  const SectionHeader({
    super.key,
    required this.title,
    this.emoji,
    this.onSeeAll,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (emoji != null) ...[
                Text(
                  emoji!,
                  style: const TextStyle(fontSize: 22),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: isDark ? AppTypography.tvHeadline : AppTypography.displayMedium,
              ),
            ],
          ),
          if (onSeeAll != null)
            TvFocusable(
              onPressed: onSeeAll,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.tvCardHover
                      : AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'See All',
                      style: TextStyle(
                        color: isDark ? AppColors.secondary : AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: isDark ? 16 : 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: isDark ? 14 : 12,
                      color: isDark ? AppColors.secondary : AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
