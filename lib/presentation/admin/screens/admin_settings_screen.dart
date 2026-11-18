import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/env_config.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/enums/app_feature.dart';
import '../../providers/auth_provider.dart';
import '../../providers/categories_provider.dart';
import '../../providers/content_provider.dart';
import '../../providers/feature_permissions_provider.dart';
import '../../shared/widgets/kids_button.dart';

class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  late TextEditingController _urlController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: EnvConfig.apiBaseUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _saveConfig() async {
    setState(() => _isSaving = true);
    final ok = await EnvConfig.updateApiBaseUrl(_urlController.text.trim());
    if (ok) {
      ref.read(apiDataSourceProvider).client.updateBaseUrl(_urlController.text.trim());
    }
    setState(() => _isSaving = false);

    if (mounted) {
      ref.read(categoriesProvider.notifier).loadCategories();
      ref.read(contentProvider.notifier).loadContent();
      ref.read(featurePermissionsProvider.notifier).loadPermissions();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok
              ? 'Kids TV API Base URL updated successfully!'
              : 'Failed to update API URL.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissions = ref.watch(featurePermissionsProvider);
    final isOnline = ref.watch(isOnlineProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Platform & Feature Settings', style: AppTypography.headlineLarge),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isOnline
                    ? AppColors.success.withAlpha(25)
                    : AppColors.warning.withAlpha(25),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isOnline ? AppColors.success : AppColors.warning,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isOnline
                        ? Icons.check_circle_rounded
                        : Icons.wifi_off_rounded,
                    color: isOnline ? AppColors.success : AppColors.warning,
                    size: 32,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isOnline
                              ? 'Connected to Kids TV API'
                              : 'Offline Mode (Hive Cache Active)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isOnline
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isOnline
                              ? 'Current API Endpoint: ${EnvConfig.apiBaseUrl}'
                              : 'Displaying cached videos, channels, and playlists locally with Hive.',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Feature Permissions Matrix (Admin-Controlled Authentication Requirements)
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(20),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shield_outlined, color: AppColors.primary, size: 26),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Feature Access & Login Rules',
                          style: AppTypography.headlineLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Control whether users must be logged in to access each feature, or allow guest access.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  ...AppFeature.values.map((feature) {
                    final requiresLogin = permissions[feature.key] ?? feature.defaultRequiresLogin;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Icon(feature.icon, color: AppColors.primary, size: 24),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  feature.label,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppColors.text,
                                  ),
                                ),
                                Text(
                                  feature.description,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: requiresLogin,
                            activeThumbColor: AppColors.primary,
                            onChanged: (val) {
                              ref
                                  .read(featurePermissionsProvider.notifier)
                                  .setFeatureRequirement(feature.key, val);
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // API Endpoint Credentials
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(20),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kids TV API Base URL', style: AppTypography.headlineLarge),
                  const SizedBox(height: 6),
                  const Text(
                    'Specify the endpoint of your Kids TV Laravel backend (e.g. http://127.0.0.1:8000/api/v1 or production URL).',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'API Base URL',
                      hintText: 'http://127.0.0.1:8000/api/v1',
                      prefixIcon: Icon(Icons.link_rounded),
                    ),
                  ),
                  const SizedBox(height: 20),
                  KidsButton(
                    label: 'Save & Update API Endpoint',
                    icon: Icons.save_rounded,
                    isLoading: _isSaving,
                    onPressed: _saveConfig,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Hive Local Storage & Documentation Info
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Local Storage & API Architecture', style: AppTypography.headlineLarge),
                  const SizedBox(height: 10),
                  const Text(
                    '• Networking: Dio with Sanctum Bearer token interceptor\n'
                    '• Local Storage: Hive TypeAdapters for fast offline caching\n'
                    '• Cache-first data loading: displays cached items immediately and refreshes from backend\n'
                    '• Centralized connectivity monitoring: auto detects offline transitions\n'
                    '• Guest access supported for public categories & content\n'
                    '• REST API Endpoints compliant with KIDS_TV_API_DOCUMENTATION.pdf',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
