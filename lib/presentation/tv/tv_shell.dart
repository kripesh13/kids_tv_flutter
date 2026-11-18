import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/tv/tv_focusable.dart';
import '../providers/auth_provider.dart';
import '../providers/platform_mode_provider.dart';
import '../shared/widgets/app_logo.dart';
import 'screens/tv_categories_screen.dart';
import 'screens/tv_home_screen.dart';
import 'screens/tv_live_tv_screen.dart';
import 'screens/tv_settings_screen.dart';
import 'screens/tv_youtube_screen.dart';

class TvShell extends ConsumerStatefulWidget {
  final int initialIndex;
  const TvShell({super.key, this.initialIndex = 0});

  @override
  ConsumerState<TvShell> createState() => _TvShellState();
}

class _TvShellState extends ConsumerState<TvShell> {
  late int _selectedIndex;
  bool _isSidebarExpanded = false;

  final List<_TvNavItem> _navItems = const [
    _TvNavItem(icon: Icons.home_rounded, label: 'Home'),
    _TvNavItem(icon: Icons.category_rounded, label: 'Categories'),
    _TvNavItem(icon: Icons.live_tv_rounded, label: 'Live TV'),
    _TvNavItem(icon: Icons.smart_display_rounded, label: 'YouTube'),
    _TvNavItem(icon: Icons.settings_rounded, label: 'Settings'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return const TvHomeScreen();
      case 1:
        return const TvCategoriesScreen();
      case 2:
        return const TvLiveTvScreen();
      case 3:
        return const TvYoutubeScreen();
      case 4:
        return const TvSettingsScreen();
      default:
        return const TvHomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.tvBackground,
      body: Row(
        children: [
          // Left Sidebar Navigation
          AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeInOutCubic,
            width: _isSidebarExpanded ? 220 : 84,
            decoration: const BoxDecoration(
              color: AppColors.tvSurface,
              border: Border(
                right: BorderSide(color: AppColors.tvCard, width: 1.5),
              ),
            ),
            child: Column(
              children: [
                // Logo Header
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: AppLogo(
                    size: 38,
                    showText: _isSidebarExpanded,
                    isDark: true,
                  ),
                ),
                const Divider(color: AppColors.tvCard, height: 1),

                // Navigation Items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    children: [
                      for (int i = 0; i < _navItems.length; i++)
                        _buildNavTile(i, _navItems[i]),
                    ],
                  ),
                ),

                // Mode switch & Admin Quick Tile
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  child: Column(
                    children: [
                      TvFocusable(
                        onPressed: () {
                          ref.read(platformModeProvider.notifier).toggleMode(context);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.tvCard,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: _isSidebarExpanded
                                ? MainAxisAlignment.start
                                : MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.phone_android_rounded,
                                  color: AppColors.secondary, size: 22),
                              if (_isSidebarExpanded) ...[
                                const SizedBox(width: 12),
                                Text(
                                  'Mobile Mode',
                                  style: AppTypography.tvTitle.copyWith(
                                    fontSize: 14,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (AppConfig.isAdminApp)
                        TvFocusable(
                          onPressed: () {
                            if (authState.isAuthenticated) {
                              context.push('/admin');
                            } else {
                              context.push('/admin/login');
                            }
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: authState.isAuthenticated
                                  ? AppColors.success.withAlpha(40)
                                  : AppColors.tvCard,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisAlignment: _isSidebarExpanded
                                  ? MainAxisAlignment.start
                                  : MainAxisAlignment.center,
                              children: [
                                Icon(
                                  authState.isAuthenticated
                                      ? Icons.admin_panel_settings_rounded
                                      : Icons.lock_outline_rounded,
                                  color: authState.isAuthenticated
                                      ? AppColors.success
                                      : AppColors.tvTextSecondary,
                                  size: 22,
                                ),
                                if (_isSidebarExpanded) ...[
                                  const SizedBox(width: 12),
                                  Text(
                                    authState.isAuthenticated ? 'Admin' : 'Admin Login',
                                    style: AppTypography.tvTitle.copyWith(
                                      fontSize: 14,
                                      color: authState.isAuthenticated
                                          ? AppColors.success
                                          : AppColors.tvText,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        )
                      else
                        TvFocusable(
                          onPressed: () {
                            if (authState.isAuthenticated) {
                              context.push('/profile');
                            } else {
                              context.push('/user-login');
                            }
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: authState.isAuthenticated
                                  ? AppColors.primary.withAlpha(40)
                                  : AppColors.tvCard,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisAlignment: _isSidebarExpanded
                                  ? MainAxisAlignment.start
                                  : MainAxisAlignment.center,
                              children: [
                                Icon(
                                  authState.isAuthenticated
                                      ? Icons.account_circle_rounded
                                      : Icons.login_rounded,
                                  color: authState.isAuthenticated
                                      ? AppColors.primary
                                      : AppColors.secondary,
                                  size: 22,
                                ),
                                if (_isSidebarExpanded) ...[
                                  const SizedBox(width: 12),
                                  Text(
                                    authState.isAuthenticated ? 'My Profile' : 'Sign In',
                                    style: AppTypography.tvTitle.copyWith(
                                      fontSize: 14,
                                      color: authState.isAuthenticated
                                          ? AppColors.primaryLight
                                          : AppColors.secondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main TV Screen Content
          Expanded(
            child: _buildScreen(_selectedIndex),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile(int index, _TvNavItem item) {
    final isSelected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: TvFocusable(
        onFocusChange: (focused) {
          if (focused) {
            setState(() => _isSidebarExpanded = true);
          }
        },
        onPressed: () {
          setState(() {
            _selectedIndex = index;
            _isSidebarExpanded = false;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment:
                _isSidebarExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                color: isSelected ? Colors.white : AppColors.tvTextSecondary,
                size: 24,
              ),
              if (_isSidebarExpanded) ...[
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.tvText,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TvNavItem {
  final IconData icon;
  final String label;
  const _TvNavItem({required this.icon, required this.label});
}
