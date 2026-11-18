import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/tv/tv_focusable.dart';
import 'app_logo.dart';
import 'kids_button.dart';

class LoginPromptBottomSheet extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onAuthenticated;

  const LoginPromptBottomSheet({
    super.key,
    this.title = 'Sign in to continue',
    this.description =
        'Create a free account or sign in to access this feature and save your favorite videos.',
    this.onAuthenticated,
  });

  static Future<void> show(
    BuildContext context, {
    String? title,
    String? description,
    VoidCallback? onAuthenticated,
  }) {
    final isWide = MediaQuery.of(context).size.width > 600;

    if (isWide) {
      return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: LoginPromptBottomSheet(
              title: title ?? 'Sign in to continue',
              description: description ??
                  'Create a free account or sign in to access this feature and save your favorite videos.',
              onAuthenticated: onAuthenticated,
            ),
          ),
        ),
      );
    }

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LoginPromptBottomSheet(
        title: title ?? 'Sign in to continue',
        description: description ??
            'Create a free account or sign in to access this feature and save your favorite videos.',
        onAuthenticated: onAuthenticated,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(40),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Drag handle for bottom sheet
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Playful Logo Badge with Lock / Star icon
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              const AppLogo(size: 60),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          Text(
            title,
            style: AppTypography.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),

          Text(
            description,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 26),

          // Buttons
          TvFocusable(
            autofocus: true,
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/user-login');
            },
            child: KidsButton(
              label: 'Sign In',
              icon: Icons.login_rounded,
              width: double.infinity,
              height: 50,
              onPressed: () {
                Navigator.of(context).pop();
                context.push('/user-login');
              },
            ),
          ),
          const SizedBox(height: 12),

          TvFocusable(
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/user-register');
            },
            child: KidsButton(
              label: 'Create Free Account',
              icon: Icons.person_add_rounded,
              variant: KidsButtonVariant.secondary,
              width: double.infinity,
              height: 50,
              onPressed: () {
                Navigator.of(context).pop();
                context.push('/user-register');
              },
            ),
          ),
          const SizedBox(height: 12),

          TvFocusable(
            onPressed: () => Navigator.of(context).pop(),
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Continue Browsing as Guest',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
