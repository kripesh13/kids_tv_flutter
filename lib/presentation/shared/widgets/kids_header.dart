import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/tv/tv_focusable.dart';
import '../../providers/auth_provider.dart';
import '../../providers/platform_mode_provider.dart';
import 'app_logo.dart';

class KidsHeader extends ConsumerWidget {
  final bool isDark;
  final VoidCallback? onSearchTap;

  const KidsHeader({
    super.key,
    this.isDark = false,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isTv = ref.watch(platformModeProvider.notifier).isTv(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App Logo
          AppLogo(
            size: isDark ? 44 : 38,
            isDark: isDark,
          ),

          // Actions Row
          Row(
            children: [
              // Search Button
              TvFocusable(
                onPressed: onSearchTap ?? () => context.push('/search'),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.tvCard : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black38 : AppColors.primary.withAlpha(25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.search_rounded,
                    size: 22,
                    color: isDark ? AppColors.tvText : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Platform Mode Switcher Pill (Mobile vs Android TV)
              TvFocusable(
                onPressed: () {
                  ref.read(platformModeProvider.notifier).toggleMode(context);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isTv
                        ? AppColors.secondary.withAlpha(isDark ? 50 : 25)
                        : AppColors.primary.withAlpha(isDark ? 50 : 20),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isTv ? AppColors.secondary : AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isTv ? Icons.tv_rounded : Icons.phone_android_rounded,
                        size: 16,
                        color: isTv ? AppColors.secondary : AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isTv ? 'TV Mode' : 'Mobile Mode',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isTv ? AppColors.secondary : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Account / Profile / Auth Pill
              if (AppConfig.isAdminApp)
                // Admin Build: Admin Portal indicator
                TvFocusable(
                  onPressed: () {
                    if (authState.isAuthenticated) {
                      context.push('/admin');
                    } else {
                      context.push('/admin/login');
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: authState.isAuthenticated
                          ? AppColors.success.withAlpha(isDark ? 40 : 20)
                          : (isDark ? AppColors.tvCard : Colors.white),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: authState.isAuthenticated
                            ? AppColors.success
                            : (isDark ? AppColors.tvCardHover : AppColors.primary.withAlpha(30)),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          authState.isAuthenticated
                              ? Icons.admin_panel_settings_rounded
                              : Icons.lock_outline_rounded,
                          size: 16,
                          color: authState.isAuthenticated
                              ? AppColors.success
                              : (isDark ? AppColors.tvText : AppColors.primary),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          authState.isAuthenticated
                              ? (authState.user?.displayName ?? 'Admin')
                              : 'Admin',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: authState.isAuthenticated
                                ? AppColors.success
                                : (isDark ? AppColors.tvText : AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                // User Build: User Profile or Sign In
                TvFocusable(
                  onPressed: () {
                    if (authState.isAuthenticated) {
                      context.push('/profile');
                    } else {
                      context.push('/user-login');
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: authState.isAuthenticated
                          ? AppColors.primary.withAlpha(isDark ? 40 : 15)
                          : (isDark ? AppColors.tvCard : Colors.white),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: authState.isAuthenticated
                            ? AppColors.primary
                            : AppColors.secondary,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          authState.isAuthenticated
                              ? Icons.account_circle_rounded
                              : Icons.login_rounded,
                          size: 16,
                          color: authState.isAuthenticated
                              ? AppColors.primary
                              : AppColors.secondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          authState.isAuthenticated
                              ? (authState.user?.displayName ?? 'Profile')
                              : 'Sign In',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: authState.isAuthenticated
                                ? AppColors.primary
                                : AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
