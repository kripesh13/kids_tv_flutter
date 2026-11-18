import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/env_config.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/local/hive_cache_manager.dart';
import 'presentation/providers/platform_mode_provider.dart';
import 'presentation/shared/widgets/offline_indicator_banner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive storage, TypeAdapters, and boxes
  await HiveCacheManager().init();

  // Load API environment configuration
  await EnvConfig.loadConfig();

  runApp(
    const ProviderScope(
      child: KidsTvApp(),
    ),
  );
}

class KidsTvApp extends ConsumerWidget {
  const KidsTvApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final isTv = ref.watch(platformModeProvider.notifier).isTv(context);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: isTv ? AppTheme.tvTheme : AppTheme.mobileTheme,
      routerConfig: router,
      builder: (context, child) => OfflineIndicatorBanner(child: child),
    );
  }
}
