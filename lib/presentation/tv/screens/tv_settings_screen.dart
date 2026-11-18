import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/config/env_config.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/auth_provider.dart';
import '../../providers/platform_mode_provider.dart';
import '../../shared/widgets/kids_button.dart';

class TvSettingsScreen extends ConsumerWidget {
  const TvSettingsScreen({super.key});

  void _showApiConfigDialog(BuildContext context, WidgetRef ref) {
    final urlController = TextEditingController(text: EnvConfig.apiBaseUrl);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.tvSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Kids TV API Configuration', style: AppTypography.tvHeadline),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter your Kids TV Laravel backend API URL (e.g. http://10.0.2.2:8000/api/v1 for emulator or production server).',
                style: TextStyle(color: AppColors.tvTextSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: urlController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'API Base URL',
                  hintText: 'http://127.0.0.1:8000/api/v1',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () async {
              final ok = await EnvConfig.updateApiBaseUrl(urlController.text.trim());
              if (ok) {
                ref.read(apiDataSourceProvider).client.updateBaseUrl(urlController.text.trim());
              }
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok
                        ? 'API endpoint saved successfully!'
                        : 'Failed to update endpoint.'),
                  ),
                );
              }
            },
            child: const Text('Save & Connect'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isOnline = ref.watch(isOnlineProvider);

    return Scaffold(
      backgroundColor: AppColors.tvBackground,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings & Configuration', style: AppTypography.tvDisplay.copyWith(fontSize: 32)),
            const SizedBox(height: 24),

            Expanded(
              child: ListView(
                children: [
                  // Platform Mode Card
                  _buildSettingCard(
                    title: 'Display Mode',
                    subtitle: 'Switch between Mobile Touch UI and Android TV Remote UI on any screen',
                    icon: Icons.tv_rounded,
                    action: KidsButton(
                      label: 'Switch to Mobile UI',
                      icon: Icons.phone_android_rounded,
                      isDark: true,
                      onPressed: () {
                        ref.read(platformModeProvider.notifier).setMode(false);
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // API Backend Status Card
                  _buildSettingCard(
                    title: 'Kids TV Backend Status',
                    subtitle: isOnline
                        ? 'Connected to Kids TV API: ${EnvConfig.apiBaseUrl}'
                        : 'Running in Offline Mode. Displaying cached content & channels using Hive.',
                    icon: isOnline ? Icons.cloud_done_rounded : Icons.wifi_off_rounded,
                    action: KidsButton(
                      label: 'Configure API',
                      icon: Icons.settings_ethernet_rounded,
                      variant: KidsButtonVariant.secondary,
                      isDark: true,
                      onPressed: () => _showApiConfigDialog(context, ref),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Account / Management Card
                  if (AppConfig.isAdminApp)
                    _buildSettingCard(
                      title: 'Admin Management Dashboard',
                      subtitle: authState.isAuthenticated
                          ? 'Signed in as ${authState.user?.displayName} (${authState.user?.role.label})'
                          : 'Sign in with your admin credentials to manage categories, videos, banners and users.',
                      icon: Icons.admin_panel_settings_rounded,
                      action: KidsButton(
                        label: authState.isAuthenticated ? 'Open Admin Panel' : 'Admin Login',
                        icon: Icons.dashboard_customize_rounded,
                        isDark: true,
                        onPressed: () {
                          if (authState.isAuthenticated) {
                            context.push('/admin');
                          } else {
                            context.push('/admin/login');
                          }
                        },
                      ),
                    ),

                  const SizedBox(height: 16),

                  // User Account Card
                  if (AppConfig.isUserApp)
                    _buildSettingCard(
                      title: 'User Profile & Library',
                      subtitle: authState.isAuthenticated
                          ? 'Logged in as ${authState.user?.displayName ?? authState.user?.email}'
                          : 'Guest Mode: Sign in to save favorites, continue watching, and access member categories.',
                      icon: Icons.account_circle_rounded,
                      action: KidsButton(
                        label: authState.isAuthenticated ? 'View Profile' : 'Sign In / Register',
                        icon: authState.isAuthenticated ? Icons.person_rounded : Icons.login_rounded,
                        isDark: true,
                        onPressed: () {
                          if (authState.isAuthenticated) {
                            context.push('/profile');
                          } else {
                            context.push('/login');
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget action,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.tvSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.tvPrimary.withAlpha(40),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.tvPrimary, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.tvTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          action,
        ],
      ),
    );
  }
}
