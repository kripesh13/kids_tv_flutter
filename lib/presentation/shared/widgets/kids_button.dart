import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/tv/tv_focusable.dart';

enum KidsButtonVariant { primary, secondary, accent, outline }

class KidsButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final KidsButtonVariant variant;
  final bool isLoading;
  final double? width;
  final double height;
  final bool isDark;
  final bool autofocus;

  const KidsButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.variant = KidsButtonVariant.primary,
    this.isLoading = false,
    this.width,
    this.height = 48,
    this.isDark = false,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor = Colors.white;
    Border? border;

    switch (variant) {
      case KidsButtonVariant.primary:
        bg = AppColors.primary;
        break;
      case KidsButtonVariant.secondary:
        bg = AppColors.secondary;
        textColor = AppColors.text;
        break;
      case KidsButtonVariant.accent:
        bg = AppColors.accent;
        break;
      case KidsButtonVariant.outline:
        bg = Colors.transparent;
        textColor = isDark ? Colors.white : AppColors.primary;
        border = Border.all(
          color: isDark ? Colors.white70 : AppColors.primary,
          width: 2,
        );
        break;
    }

    return TvFocusable(
      autofocus: autofocus,
      onPressed: isLoading ? null : onPressed,
      borderRadius: BorderRadius.circular(height * 0.35),
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(height * 0.35),
          border: border,
          boxShadow: variant != KidsButtonVariant.outline
              ? [
                  BoxShadow(
                    color: bg.withAlpha(90),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: textColor,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: textColor, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: AppTypography.labelLarge.copyWith(
                        color: textColor,
                        fontSize: isDark ? 16 : 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
