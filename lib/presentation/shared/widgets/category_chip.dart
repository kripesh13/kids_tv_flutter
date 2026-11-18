import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/tv/tv_focusable.dart';
import '../../../data/models/category_model.dart';

class CategoryChip extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isDark;
  final bool compact;

  const CategoryChip({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
    this.isDark = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final catColor = category.color;

    return TvFocusable(
      onPressed: onTap,
      borderRadius: BorderRadius.circular(compact ? 24 : 18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: compact
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? catColor
              : (isDark ? AppColors.tvCard : Colors.white),
          borderRadius: BorderRadius.circular(compact ? 24 : 18),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? catColor.withAlpha(90)
                  : (isDark ? Colors.black38 : AppColors.primary.withAlpha(20)),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: isSelected
                ? catColor
                : (isDark
                    ? AppColors.tvCardHover
                    : AppColors.primary.withAlpha(25)),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withAlpha(40)
                    : catColor.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(
                category.icon,
                size: compact ? 16 : 20,
                color: isSelected ? Colors.white : catColor,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              category.name,
              style: (isDark ? AppTypography.tvTitle : AppTypography.titleMedium).copyWith(
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.tvText : AppColors.text),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontSize: compact ? 13 : (isDark ? 16 : 14),
              ),
            ),
            if (category.requiresLogin) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.lock_rounded,
                size: compact ? 12 : 14,
                color: isSelected ? Colors.white70 : AppColors.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
