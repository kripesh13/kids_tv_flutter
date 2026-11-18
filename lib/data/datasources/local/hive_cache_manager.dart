import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/enums/app_feature.dart';
import '../../../domain/enums/banner_action.dart';
import '../../../domain/enums/content_type.dart';
import '../../../domain/enums/user_role.dart';
import '../../models/banner_model.dart';
import '../../models/category_model.dart';
import '../../models/content_item_model.dart';
import '../../models/favorite_item_model.dart';
import '../../models/feature_permission_model.dart';
import '../../models/live_channel_model.dart';
import '../../models/user_profile_model.dart';
import '../../models/watch_history_model.dart';
import '../../models/youtube_channel_model.dart';
import '../mock_seed_data.dart';

class HiveCacheManager {
  static final HiveCacheManager _instance = HiveCacheManager._internal();
  factory HiveCacheManager() => _instance;
  HiveCacheManager._internal();

  bool _isInitialized = false;

  late Box<CategoryModel> _categoriesBox;
  late Box<ContentItemModel> _contentBox;
  late Box<BannerModel> _bannersBox;
  late Box<LiveChannelModel> _liveChannelsBox;
  late Box<YoutubeChannelModel> _youtubeBox;
  late Box<FeaturePermissionModel> _permissionsBox;
  late Box<WatchHistoryModel> _watchHistoryBox;
  late Box _authBox;
  late Box _settingsBox;

  Box get settingsBox => _settingsBox;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await Hive.initFlutter();

      _registerAdapterSafe(ContentTypeAdapter());
      _registerAdapterSafe(BannerActionAdapter());
      _registerAdapterSafe(UserRoleAdapter());
      _registerAdapterSafe(CategoryModelAdapter());
      _registerAdapterSafe(ContentItemModelAdapter());
      _registerAdapterSafe(BannerModelAdapter());
      _registerAdapterSafe(LiveChannelModelAdapter());
      _registerAdapterSafe(YoutubeChannelModelAdapter());
      _registerAdapterSafe(UserProfileAdapter());
      _registerAdapterSafe(FeaturePermissionModelAdapter());
      _registerAdapterSafe(WatchHistoryModelAdapter());
      _registerAdapterSafe(FavoriteItemModelAdapter());

      _categoriesBox = await Hive.openBox<CategoryModel>(AppConstants.categoriesBox);
      _contentBox = await Hive.openBox<ContentItemModel>(AppConstants.contentBox);
      _bannersBox = await Hive.openBox<BannerModel>(AppConstants.bannersBox);
      _liveChannelsBox = await Hive.openBox<LiveChannelModel>(AppConstants.liveTvBox);
      _youtubeBox = await Hive.openBox<YoutubeChannelModel>(AppConstants.youtubeBox);
      _permissionsBox = await Hive.openBox<FeaturePermissionModel>(AppConstants.permissionsBox);
      _watchHistoryBox = await Hive.openBox<WatchHistoryModel>(AppConstants.watchHistoryBox);
      _authBox = await Hive.openBox(AppConstants.authBox);
      _settingsBox = await Hive.openBox(AppConstants.settingsBox);

      _isInitialized = true;
      debugPrint('HiveCacheManager initialized successfully.');

      // Seed initial offline mock data if boxes are empty on first run
      _seedInitialDataIfEmpty();
    } catch (e) {
      debugPrint('HiveCacheManager init error: $e');
    }
  }

  void _registerAdapterSafe<T>(TypeAdapter<T> adapter) {
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }
  }

  void _seedInitialDataIfEmpty() {
    if (_categoriesBox.isEmpty) {
      for (final cat in MockSeedData.initialCategories) {
        _categoriesBox.put(cat.id, cat);
      }
    }
    if (_contentBox.isEmpty) {
      for (final item in MockSeedData.initialContentItems) {
        _contentBox.put(item.id, item);
      }
    }
    if (_bannersBox.isEmpty) {
      for (final b in MockSeedData.initialBanners) {
        _bannersBox.put(b.id, b);
      }
    }
    if (_liveChannelsBox.isEmpty) {
      for (final ch in MockSeedData.initialLiveChannels) {
        _liveChannelsBox.put(ch.id, ch);
      }
    }
    if (_youtubeBox.isEmpty) {
      for (final yt in MockSeedData.initialYoutubeChannels) {
        _youtubeBox.put(yt.id, yt);
      }
    }
    if (_permissionsBox.isEmpty) {
      for (final perm in MockSeedData.initialFeaturePermissions) {
        _permissionsBox.put(perm.featureKey, perm);
      }
    }
  }

  // ===========================================================================
  // AUTH & TOKEN
  // ===========================================================================
  String? getAuthToken() {
    return _authBox.get(AppConstants.keyAuthToken) as String?;
  }

  Future<void> saveAuthToken(String token) async {
    await _authBox.put(AppConstants.keyAuthToken, token);
  }

  UserProfile? getCurrentUser() {
    final user = _authBox.get(AppConstants.keyCurrentUser);
    if (user is UserProfile) return user;
    if (user is Map) {
      return UserProfile.fromJson(Map<String, dynamic>.from(user));
    }
    return null;
  }

  Future<void> saveCurrentUser(UserProfile user) async {
    await _authBox.put(AppConstants.keyCurrentUser, user);
  }

  Future<void> clearAuth() async {
    await _authBox.delete(AppConstants.keyAuthToken);
    await _authBox.delete(AppConstants.keyCurrentUser);
  }

  // ===========================================================================
  // CATEGORIES CACHE
  // ===========================================================================
  List<CategoryModel> getCachedCategories({bool onlyVisible = true}) {
    final list = _categoriesBox.values.where((c) => !onlyVisible || c.isVisible).toList();
    list.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return list;
  }

  Future<void> cacheCategories(List<CategoryModel> categories) async {
    await _categoriesBox.clear();
    for (final c in categories) {
      await _categoriesBox.put(c.id, c);
    }
  }

  Future<void> saveCategory(CategoryModel category) async {
    await _categoriesBox.put(category.id, category);
  }

  Future<void> deleteCategory(String id) async {
    await _categoriesBox.delete(id);
  }

  // ===========================================================================
  // CONTENT ITEMS CACHE
  // ===========================================================================
  List<ContentItemModel> getCachedContentItems({
    String? categoryId,
    bool? isFeatured,
    bool onlyVisible = true,
    int? limit,
    int? offset,
    String? searchQuery,
  }) {
    var items = _contentBox.values.where((item) {
      if (onlyVisible && !item.isVisible) return false;
      if (categoryId != null && item.categoryId != categoryId) return false;
      if (isFeatured != null && item.isFeatured != isFeatured) return false;
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.toLowerCase().trim();
        final matchesTitle = item.title.toLowerCase().contains(q);
        final matchesDesc = item.description?.toLowerCase().contains(q) ?? false;
        final matchesTag = item.tags.any((t) => t.toLowerCase().contains(q));
        if (!matchesTitle && !matchesDesc && !matchesTag) return false;
      }
      return true;
    }).toList();

    items.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    if (offset != null && offset > 0) {
      if (offset >= items.length) return [];
      items = items.sublist(offset);
    }
    if (limit != null && items.length > limit) {
      items = items.sublist(0, limit);
    }
    return items;
  }

  Future<void> cacheContentItems(List<ContentItemModel> items) async {
    for (final item in items) {
      await _contentBox.put(item.id, item);
    }
  }

  Future<void> saveContentItem(ContentItemModel item) async {
    await _contentBox.put(item.id, item);
  }

  Future<void> deleteContentItem(String id) async {
    await _contentBox.delete(id);
  }

  Future<void> incrementViews(String id) async {
    final existing = _contentBox.get(id);
    if (existing != null) {
      final updated = existing.copyWith(viewsCount: existing.viewsCount + 1);
      await _contentBox.put(id, updated);
    }
  }

  // ===========================================================================
  // BANNERS CACHE
  // ===========================================================================
  List<BannerModel> getCachedBanners({bool onlyActive = true}) {
    final list = _bannersBox.values.where((b) => !onlyActive || b.isActive).toList();
    list.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return list;
  }

  Future<void> cacheBanners(List<BannerModel> banners) async {
    await _bannersBox.clear();
    for (final b in banners) {
      await _bannersBox.put(b.id, b);
    }
  }

  Future<void> saveBanner(BannerModel banner) async {
    await _bannersBox.put(banner.id, banner);
  }

  Future<void> deleteBanner(String id) async {
    await _bannersBox.delete(id);
  }

  // ===========================================================================
  // LIVE TV CACHE
  // ===========================================================================
  List<LiveChannelModel> getCachedLiveChannels({bool onlyActive = true}) {
    final list = _liveChannelsBox.values.where((c) => !onlyActive || c.isActive).toList();
    list.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return list;
  }

  Future<void> cacheLiveChannels(List<LiveChannelModel> channels) async {
    await _liveChannelsBox.clear();
    for (final ch in channels) {
      await _liveChannelsBox.put(ch.id, ch);
    }
  }

  Future<void> saveLiveChannel(LiveChannelModel channel) async {
    await _liveChannelsBox.put(channel.id, channel);
  }

  Future<void> deleteLiveChannel(String id) async {
    await _liveChannelsBox.delete(id);
  }

  // ===========================================================================
  // YOUTUBE CHANNELS CACHE
  // ===========================================================================
  List<YoutubeChannelModel> getCachedYoutubeChannels() {
    final list = _youtubeBox.values.toList();
    list.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return list;
  }

  Future<void> cacheYoutubeChannels(List<YoutubeChannelModel> channels) async {
    await _youtubeBox.clear();
    for (final ch in channels) {
      await _youtubeBox.put(ch.id, ch);
    }
  }

  // ===========================================================================
  // FEATURE PERMISSIONS CACHE
  // ===========================================================================
  Map<String, bool> getCachedFeaturePermissions() {
    final map = <String, bool>{};
    for (final perm in _permissionsBox.values) {
      map[perm.featureKey] = perm.requiresLogin;
    }
    // Merge with defaults
    for (final f in AppFeature.values) {
      map.putIfAbsent(f.key, () => f.defaultRequiresLogin);
    }
    return map;
  }

  Future<void> cacheFeaturePermissions(Map<String, bool> permissions) async {
    for (final entry in permissions.entries) {
      final model = FeaturePermissionModel(
        featureKey: entry.key,
        requiresLogin: entry.value,
        updatedAt: DateTime.now(),
      );
      await _permissionsBox.put(entry.key, model);
    }
  }

  Future<void> updateFeaturePermission(String featureKey, bool requiresLogin) async {
    final model = FeaturePermissionModel(
      featureKey: featureKey,
      requiresLogin: requiresLogin,
      updatedAt: DateTime.now(),
    );
    await _permissionsBox.put(featureKey, model);
  }

  // ===========================================================================
  // FAVORITES CACHE
  // ===========================================================================
  Set<String> getCachedFavoriteIds() {
    final raw = _authBox.get(AppConstants.keyFavorites);
    if (raw is List) {
      return Set<String>.from(raw.map((e) => e.toString()));
    }
    return {};
  }

  Future<void> setCachedFavoriteIds(Set<String> ids) async {
    await _authBox.put(AppConstants.keyFavorites, ids.toList());
  }

  Future<bool> toggleCachedFavorite(String contentId) async {
    final current = getCachedFavoriteIds();
    final isFav = current.contains(contentId);
    if (isFav) {
      current.remove(contentId);
    } else {
      current.add(contentId);
    }
    await setCachedFavoriteIds(current);
    return !isFav;
  }

  // ===========================================================================
  // LIKES CACHE
  // ===========================================================================
  Set<String> getCachedLikedIds() {
    final raw = _authBox.get('user_likes');
    if (raw is List) {
      return Set<String>.from(raw.map((e) => e.toString()));
    }
    return {};
  }

  Future<void> setCachedLikedIds(Set<String> ids) async {
    await _authBox.put('user_likes', ids.toList());
  }

  Future<bool> toggleCachedLike(String contentId) async {
    final current = getCachedLikedIds();
    final isLiked = current.contains(contentId);
    if (isLiked) {
      current.remove(contentId);
    } else {
      current.add(contentId);
    }
    await setCachedLikedIds(current);
    return !isLiked;
  }

  // ===========================================================================
  // WATCH HISTORY CACHE
  // ===========================================================================
  List<WatchHistoryModel> getCachedWatchHistory() {
    final list = _watchHistoryBox.values.toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  Future<void> cacheWatchHistory(List<WatchHistoryModel> history) async {
    await _watchHistoryBox.clear();
    for (final h in history) {
      await _watchHistoryBox.put(h.id, h);
    }
  }

  Future<void> updateWatchHistory(WatchHistoryModel item) async {
    await _watchHistoryBox.put(item.id, item);
  }

  Future<void> clearWatchHistory() async {
    await _watchHistoryBox.clear();
  }
}
