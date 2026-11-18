import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'kids_button.dart';

class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String? message;
  final VoidCallback? onRetry;
  final bool isDark;

  const ErrorStateWidget({
    super.key,
    this.title = 'Oops! Something went wrong',
    this.message,
    this.onRetry,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.accent.withAlpha(isDark ? 40 : 25),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.sentiment_dissatisfied_rounded,
                  size: 40,
                  color: AppColors.accent,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: (isDark ? AppTypography.tvHeadline : AppTypography.displayMedium).copyWith(
                color: isDark ? AppColors.tvText : AppColors.text,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? AppColors.tvTextSecondary : AppColors.textSecondary,
                ),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              KidsButton(
                label: 'Try Again',
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
                isDark: isDark,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
