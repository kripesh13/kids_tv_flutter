import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/env_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/auth_provider.dart';
import '../../providers/categories_provider.dart';
import '../../providers/content_provider.dart';
import '../../providers/live_tv_provider.dart';
import '../../shared/widgets/app_logo.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final categoriesState = ref.watch(categoriesProvider);
    final contentState = ref.watch(contentProvider);
    final liveTvState = ref.watch(liveTvProvider);

    final totalViews = contentState.items.fold<int>(0, (sum, item) => sum + item.viewsCount);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            const AppLogo(size: 32, showText: false),
            const SizedBox(width: 10),
            Text('Admin Dashboard', style: AppTypography.headlineLarge),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            label: const Text('Back to App'),
            onPressed: () => context.go('/'),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            tooltip: 'Sign Out',
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/');
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Profile & Role Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(70),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white24,
                    child: Text(
                      (user?.displayName?.isNotEmpty == true
                              ? user!.displayName![0]
                              : user?.email.isNotEmpty == true
                                  ? user!.email[0]
                                  : 'A')
                          .toUpperCase(),
                      style: const TextStyle(
                        fontSize: 26,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, ${user?.displayName ?? user?.email ?? "Admin"}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                user?.role.label.toUpperCase() ?? 'ADMIN',
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              EnvConfig.isConfigured
                                  ? 'Connected to API: ${EnvConfig.apiBaseUrl}'
                                  : 'Running in Local Cache Mode',
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Statistics Metrics Row
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Categories',
                    count: '${categoriesState.categories.length}',
                    icon: Icons.category_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Content Items',
                    count: '${contentState.items.length}',
                    icon: Icons.movie_filter_rounded,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Total Views',
                    count: '$totalViews',
                    icon: Icons.visibility_rounded,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Live Channels',
                    count: '${liveTvState.channels.length}',
                    icon: Icons.live_tv_rounded,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Management Modules Grid
            Text('Content & Platform Management', style: AppTypography.headlineLarge),
            const SizedBox(height: 14),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildActionCard(
                  title: 'Categories Management',
                  description: 'Add, edit, reorder, delete, and feature categories dynamically.',
                  icon: Icons.category_rounded,
                  color: AppColors.primary,
                  onTap: () => context.push('/admin/categories'),
                ),
                _buildActionCard(
                  title: 'Universal Content Management',
                  description: 'Manage self-uploaded videos, YouTube streams, cartoons and episodes.',
                  icon: Icons.video_library_rounded,
                  color: AppColors.accent,
                  onTap: () => context.push('/admin/content'),
                ),
                _buildActionCard(
                  title: 'Featured Banners Manager',
                  description: 'Update the home and TV carousel billboards and spotlights.',
                  icon: Icons.view_carousel_rounded,
                  color: AppColors.secondary,
                  onTap: () => context.push('/admin/banners'),
                ),
                _buildActionCard(
                  title: 'Live TV Channels Manager',
                  description: 'Add, edit HLS m3u8 live stream channels and current programs.',
                  icon: Icons.live_tv_rounded,
                  color: AppColors.success,
                  onTap: () => context.push('/admin/live-tv'),
                ),
                if (user?.role.canManageUsers == true)
                  _buildActionCard(
                    title: 'User Roles & RBAC',
                    description: 'Super Admin: Manage administrator, editor, and viewer roles.',
                    icon: Icons.people_alt_rounded,
                    color: AppColors.purple,
                    onTap: () => context.push('/admin/users'),
                  ),
                _buildActionCard(
                  title: 'Kids TV API & Server Config',
                  description: 'Configure Laravel API Base URL, endpoints, and Hive cache storage.',
                  icon: Icons.cloud_sync_rounded,
                  color: AppColors.cyan,
                  onTap: () => context.push('/admin/settings'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            count,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha(40)),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}
