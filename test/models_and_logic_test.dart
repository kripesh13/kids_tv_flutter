import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kids_tv/core/config/app_config.dart';
import 'package:kids_tv/core/services/access_control_service.dart';
import 'package:kids_tv/data/datasources/local/hive_cache_manager.dart';
import 'package:kids_tv/data/datasources/mock_seed_data.dart';
import 'package:kids_tv/data/datasources/remote/api_data_source.dart';
import 'package:kids_tv/data/models/category_model.dart';
import 'package:kids_tv/data/models/content_item_model.dart';
import 'package:kids_tv/data/models/feature_permission_model.dart';
import 'package:kids_tv/data/models/watch_history_model.dart';
import 'package:kids_tv/domain/enums/app_feature.dart';
import 'package:kids_tv/domain/enums/content_type.dart';
import 'package:kids_tv/domain/enums/user_role.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = await Directory.systemTemp.createTemp('kids_tv_test_');
    await HiveCacheManager().init(tempDir.path);
  });

  tearDownAll(() async {
    try {
      await Hive.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    } catch (_) {}
  });
  group('1. Centralized Build Types & AppConfig', () {
    test('AppType has exactly admin and user values', () {
      expect(AppType.values, containsAll([AppType.admin, AppType.user]));
      expect(AppType.values.length, equals(2));
    });

    test('AppConfig flags reflect configured AppType correctly', () {
      if (AppConfig.appType == AppType.user) {
        expect(AppConfig.isUserApp, isTrue);
        expect(AppConfig.isAdminApp, isFalse);
      } else {
        expect(AppConfig.isAdminApp, isTrue);
        expect(AppConfig.isUserApp, isFalse);
      }
    });
  });

  group('2. UserRole - Strictly Two Roles (Admin & User)', () {
    test('Admin role has full administrative permissions', () {
      const role = UserRole.admin;
      expect(role.isAdmin, isTrue);
      expect(role.isUser, isFalse);
      expect(role.canManageUsers, isTrue);
      expect(role.canDeleteContent, isTrue);
      expect(role.canEditContent, isTrue);
      expect(role.canManageCategories, isTrue);
      expect(role.canDeleteCategories, isTrue);
      expect(role.isAdminPortalUser, isTrue);
    });

    test('User role has no administrative rights', () {
      const role = UserRole.user;
      expect(role.isAdmin, isFalse);
      expect(role.isUser, isTrue);
      expect(role.canManageUsers, isFalse);
      expect(role.canDeleteContent, isFalse);
      expect(role.canEditContent, isFalse);
      expect(role.canManageCategories, isFalse);
      expect(role.canDeleteCategories, isFalse);
      expect(role.isAdminPortalUser, isFalse);
    });

    test('fromString cleanly normalizes strings to Admin or User', () {
      expect(UserRole.fromString('admin'), equals(UserRole.admin));
      expect(UserRole.fromString('super_admin'), equals(UserRole.admin));
      expect(UserRole.fromString('editor'), equals(UserRole.admin));
      expect(UserRole.fromString('user'), equals(UserRole.user));
      expect(UserRole.fromString('viewer'), equals(UserRole.user));
      expect(UserRole.fromString(null), equals(UserRole.user));
    });
  });

  group('3. CategoryModel Login & Interaction Restrictions', () {
    test('Correctly serializes and deserializes requiresLogin, allowFavorites, allowSharing', () {
      final json = {
        'id': 'cat-sports',
        'name': 'Sports & Action',
        'slug': 'sports',
        'color_hex': '#42C98A',
        'icon_name': 'sports_soccer',
        'display_order': 4,
        'is_featured': true,
        'is_visible': true,
        'requires_login': true,
        'allow_favorites': false,
        'allow_sharing': true,
      };

      final cat = CategoryModel.fromJson(json);
      expect(cat.id, 'cat-sports');
      expect(cat.name, 'Sports & Action');
      expect(cat.requiresLogin, isTrue);
      expect(cat.allowFavorites, isFalse);
      expect(cat.allowSharing, isTrue);

      final backToJson = cat.toJson();
      expect(backToJson['requires_login'], isTrue);
      expect(backToJson['allow_favorites'], isFalse);
      expect(backToJson['allow_sharing'], isTrue);
    });

    test('Defaults to requiresLogin: false, allowFavorites: true, allowSharing: true when absent', () {
      final json = {
        'id': 'cat-rhymes',
        'name': 'Rhymes',
        'slug': 'rhymes',
      };

      final cat = CategoryModel.fromJson(json);
      expect(cat.requiresLogin, isFalse);
      expect(cat.allowFavorites, isTrue);
      expect(cat.allowSharing, isTrue);
    });

    test('Mock seed data contains Sports category configured with requiresLogin: true', () {
      final sports = MockSeedData.initialCategories.firstWhere((c) => c.slug == 'sports');
      expect(sports.requiresLogin, isTrue);
      expect(sports.allowFavorites, isTrue);
      expect(sports.allowSharing, isTrue);
    });
  });

  group('4. AppFeature & FeaturePermissionModel', () {
    test('Contains all required platform features', () {
      expect(AppFeature.values.length, equals(9));
      expect(AppFeature.browseVideos.key, equals('browse_videos'));
      expect(AppFeature.watchVideos.key, equals('watch_videos'));
      expect(AppFeature.favorites.key, equals('favorites'));
      expect(AppFeature.likes.key, equals('likes'));
      expect(AppFeature.watchHistory.key, equals('watch_history'));
      expect(AppFeature.continueWatching.key, equals('continue_watching'));
      expect(AppFeature.restrictedCategories.key, equals('restricted_categories'));
      expect(AppFeature.search.key, equals('search'));
      expect(AppFeature.shareVideos.key, equals('share_videos'));
    });

    test('FeaturePermissionModel serialization works correctly', () {
      final now = DateTime.now();
      final model = FeaturePermissionModel(
        featureKey: 'watch_videos',
        requiresLogin: true,
        description: 'Playback test',
        updatedAt: now,
      );

      final json = model.toJson();
      expect(json['feature_key'], 'watch_videos');
      expect(json['requires_login'], isTrue);
      expect(json['description'], 'Playback test');

      final fromJson = FeaturePermissionModel.fromJson(json);
      expect(fromJson.featureKey, 'watch_videos');
      expect(fromJson.requiresLogin, isTrue);
      expect(fromJson.description, 'Playback test');
    });
  });

  group('5. AccessControlService Logic (Guest vs Authenticated)', () {
    test('Guest user cannot access login-required categories but can access public ones', () {
      const guestService = AccessControlService(
        isAuthenticated: false,
        featureSettings: {},
      );

      // Public category
      final rhymesCat = CategoryModel(
        id: '1',
        name: 'Rhymes',
        slug: 'rhymes',
        requiresLogin: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(guestService.canAccessCategory(requiresLogin: rhymesCat.requiresLogin), isTrue);

      // Restricted category
      final sportsCat = CategoryModel(
        id: '2',
        name: 'Sports',
        slug: 'sports',
        requiresLogin: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(guestService.canAccessCategory(requiresLogin: sportsCat.requiresLogin), isFalse);
    });

    test('Authenticated user can access all categories', () {
      const authService = AccessControlService(
        isAuthenticated: true,
        featureSettings: {},
      );

      final sportsCat = CategoryModel(
        id: '2',
        name: 'Sports',
        slug: 'sports',
        requiresLogin: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(authService.canAccessCategory(requiresLogin: sportsCat.requiresLogin), isTrue);
    });

    test('Guest cannot use member-only features (favorites, likes, watch history, continue watching)', () {
      const guestService = AccessControlService(
        isAuthenticated: false,
        featureSettings: {},
      );

      expect(guestService.canUseFeature(AppFeature.favorites), isFalse);
      expect(guestService.canUseFeature(AppFeature.likes), isFalse);
      expect(guestService.canUseFeature(AppFeature.watchHistory), isFalse);
      expect(guestService.canUseFeature(AppFeature.continueWatching), isFalse);
      expect(guestService.canUseFeature(AppFeature.browseVideos), isTrue);
      expect(guestService.canUseFeature(AppFeature.search), isTrue);
      expect(guestService.canUseFeature(AppFeature.shareVideos), isTrue);
    });

    test('Admin dynamic permissions override default feature access for guests', () {
      // Admin configures 'watch_videos' to require login
      const guestServiceWithRestriction = AccessControlService(
        isAuthenticated: false,
        featureSettings: {
          'watch_videos': true,
        },
      );

      expect(guestServiceWithRestriction.canUseFeature(AppFeature.watchVideos), isFalse);

      // Authenticated user can still watch
      const authServiceWithRestriction = AccessControlService(
        isAuthenticated: true,
        featureSettings: {
          'watch_videos': true,
        },
      );
      expect(authServiceWithRestriction.canUseFeature(AppFeature.watchVideos), isTrue);
    });
  });

  group('6. WatchHistoryModel Progress and Duration Calculation', () {
    test('Computes progress percentage and handles zero duration safely', () {
      final item = WatchHistoryModel(
        id: 'wh-1',
        userId: 'u1',
        contentId: 'c1',
        lastPositionSeconds: 60,
        totalDurationSeconds: 120,
        completed: false,
        updatedAt: DateTime.now(),
      );

      expect(item.progressPercentage, equals(0.50));

      // Zero total duration safety
      final zeroDuration = item.copyWith(totalDurationSeconds: 0);
      expect(zeroDuration.progressPercentage, equals(0.0));
    });
  });

  group('7. ContentItemModel Duration Formatting', () {
    test('Formats duration correctly in MM:SS and HH:MM:SS', () {
      final shortVideo = ContentItemModel(
        id: '1',
        title: 'Song',
        thumbnailUrl: '',
        sourceUrl: '',
        durationSeconds: 185, // 3 min 5 sec
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(shortVideo.formattedDuration, '3:05');

      final longVideo = ContentItemModel(
        id: '2',
        title: 'Movie',
        thumbnailUrl: '',
        sourceUrl: '',
        durationSeconds: 3725, // 1h 2m 5s
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(longVideo.formattedDuration, '1:02:05');

      final liveStream = ContentItemModel(
        id: '3',
        title: 'Live',
        contentType: ContentType.liveStream,
        thumbnailUrl: '',
        sourceUrl: 'https://test.m3u8',
        durationSeconds: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(liveStream.isLive, isTrue);
      expect(liveStream.formattedDuration, 'LIVE');
    });
  });

  group('8. ApiDataSource & HiveCacheManager - Local Cache, Features, Favorites, Likes, History', () {
    test('Feature permissions get and update dynamically in Hive cache', () async {
      final ds = ApiDataSource();
      final permissions = await ds.getFeaturePermissions();
      expect(permissions.containsKey('favorites'), isTrue);

      // Update permission
      await ds.updateFeaturePermission('search', true);
      final updatedPermissions = await ds.getFeaturePermissions();
      expect(updatedPermissions['search'], isTrue);
    });

    test('Unauthenticated user cannot toggle favorites or likes', () async {
      final ds = ApiDataSource();
      // Ensure cache auth is clear
      await ds.signOut();
      expect(() => ds.toggleFavorite('c1'), throwsA(isA<Exception>()));
      expect(() => ds.toggleLike('c1'), throwsA(isA<Exception>()));
    });

    test('Authenticated user can toggle favorites, likes, and record watch history', () async {
      final ds = ApiDataSource();
      // Sign in demo admin/user
      await ds.signInWithDemo(role: UserRole.admin);

      // Toggle favorite
      final isFavAdded = await ds.toggleFavorite('c1');
      expect(isFavAdded, isTrue);
      var favIds = await ds.getFavoriteContentIds();
      expect(favIds.contains('c1'), isTrue);

      final isFavRemoved = await ds.toggleFavorite('c1');
      expect(isFavRemoved, isFalse);
      favIds = await ds.getFavoriteContentIds();
      expect(favIds.contains('c1'), isFalse);

      // Toggle like
      final isLiked = await ds.toggleLike('c1');
      expect(isLiked, isTrue);

      // Record watch history
      await ds.updateWatchHistory(
        contentId: 'c1',
        positionSeconds: 45,
        totalDurationSeconds: 120,
      );
      final history = await ds.getWatchHistory();
      expect(history.any((h) => h.contentId == 'c1'), isTrue);
      expect(history.first.lastPositionSeconds, equals(45));

      // Clear history
      await ds.clearWatchHistory();
      final clearedHistory = await ds.getWatchHistory();
      expect(clearedHistory.isEmpty, isTrue);
    });
  });
}
