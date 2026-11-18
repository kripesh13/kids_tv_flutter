import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool isDark;

  const AppLogo({
    super.key,
    this.size = 40,
    this.showText = true,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: AppColors.rainbowGradient,
            borderRadius: BorderRadius.circular(size * 0.32),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(80),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.play_arrow_rounded,
              size: size * 0.65,
              color: Colors.white,
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 10),
          RichText(
            text: TextSpan(
              style: isDark ? AppTypography.tvHeadline : AppTypography.displayMedium,
              children: [
                const TextSpan(
                  text: 'Kids',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: 'TV',
                  style: TextStyle(
                    color: isDark ? AppColors.secondary : AppColors.accent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
