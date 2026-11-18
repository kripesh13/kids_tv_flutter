import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../config/app_config.dart';
import '../../presentation/admin/screens/admin_dashboard_screen.dart';
import '../../presentation/admin/screens/admin_login_screen.dart';
import '../../presentation/admin/screens/admin_settings_screen.dart';
import '../../presentation/admin/screens/banner_management_screen.dart';
import '../../presentation/admin/screens/category_management_screen.dart';
import '../../presentation/admin/screens/content_management_screen.dart';
import '../../presentation/admin/screens/live_tv_management_screen.dart';
import '../../presentation/admin/screens/user_management_screen.dart';
import '../../presentation/mobile/mobile_shell.dart';
import '../../presentation/mobile/screens/mobile_category_screen.dart';
import '../../presentation/mobile/screens/mobile_live_tv_screen.dart';
import '../../presentation/mobile/screens/mobile_search_screen.dart';
import '../../presentation/mobile/screens/mobile_video_details_screen.dart';
import '../../presentation/mobile/screens/mobile_video_player_screen.dart';
import '../../presentation/mobile/screens/mobile_youtube_screen.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/platform_mode_provider.dart';
import '../../presentation/tv/screens/tv_categories_screen.dart';
import '../../presentation/tv/screens/tv_video_details_screen.dart';
import '../../presentation/tv/screens/tv_video_player_screen.dart';
import '../../presentation/tv/tv_shell.dart';
import '../../presentation/user_auth/favorites_screen.dart';
import '../../presentation/user_auth/forgot_password_screen.dart';
import '../../presentation/user_auth/history_screen.dart';
import '../../presentation/user_auth/user_login_screen.dart';
import '../../presentation/user_auth/user_profile_screen.dart';
import '../../presentation/user_auth/user_register_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final isAdminBuild = AppConfig.isAdminApp;

  if (isAdminBuild) {
    // =========================================================================
    // ADMIN APPLICATION BUILD ROUTER
    // =========================================================================
    return GoRouter(
      initialLocation: '/admin',
      redirect: (context, state) {
        final authState = ref.read(authProvider);
        final isLoggingIn = state.matchedLocation == '/admin/login';

        if (!authState.isAuthenticated && !isLoggingIn) {
          return '/admin/login';
        }
        if (authState.isAuthenticated && isLoggingIn) {
          return '/admin';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          redirect: (_, _) => '/admin',
        ),
        GoRoute(
          path: '/admin/login',
          builder: (context, state) => const AdminLoginScreen(),
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: '/admin/categories',
          builder: (context, state) => const CategoryManagementScreen(),
        ),
        GoRoute(
          path: '/admin/content',
          builder: (context, state) => const ContentManagementScreen(),
        ),
        GoRoute(
          path: '/admin/banners',
          builder: (context, state) => const BannerManagementScreen(),
        ),
        GoRoute(
          path: '/admin/live-tv',
          builder: (context, state) => const LiveTvManagementScreen(),
        ),
        GoRoute(
          path: '/admin/users',
          builder: (context, state) => const UserManagementScreen(),
        ),
        GoRoute(
          path: '/admin/settings',
          builder: (context, state) => const AdminSettingsScreen(),
        ),
      ],
    );
  }

  // ===========================================================================
  // USER APPLICATION BUILD ROUTER (NO ADMIN SCREENS EXPOSED)
  // ===========================================================================
  return GoRouter(
    initialLocation: '/',
    routes: [
      // Platform-Aware Adaptive Root (Mobile vs TV)
      GoRoute(
        path: '/',
        builder: (context, state) {
          final isTv = ref.watch(platformModeProvider.notifier).isTv(context);
          if (isTv) {
            return const TvShell(initialIndex: 0);
          }
          return const MobileShell(initialIndex: 0);
        },
      ),

      // User Authentication & Profile Routes
      GoRoute(
        path: '/user-login',
        builder: (context, state) => const UserLoginScreen(),
      ),
      GoRoute(
        path: '/user-register',
        builder: (context, state) => const UserRegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const UserProfileScreen(),
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
      ),

      // Mobile Content Routes
      GoRoute(
        path: '/categories',
        builder: (context, state) => const MobileCategoryScreen(),
      ),
      GoRoute(
        path: '/category/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return MobileCategoryScreen(initialCategoryId: id);
        },
      ),
      GoRoute(
        path: '/video/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return MobileVideoDetailsScreen(videoId: id);
        },
      ),
      GoRoute(
        path: '/player/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return MobileVideoPlayerScreen(videoId: id);
        },
      ),
      GoRoute(
        path: '/live-tv',
        builder: (context, state) => const MobileLiveTvScreen(),
      ),
      GoRoute(
        path: '/youtube',
        builder: (context, state) => const MobileYoutubeScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const MobileSearchScreen(),
      ),

      // Android TV Specific Routes
      GoRoute(
        path: '/tv-category/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return TvCategoriesScreen(initialCategoryId: id);
        },
      ),
      GoRoute(
        path: '/tv-video/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return TvVideoDetailsScreen(videoId: id);
        },
      ),
      GoRoute(
        path: '/tv-player/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return TvVideoPlayerScreen(videoId: id);
        },
      ),
    ],
  );
});
