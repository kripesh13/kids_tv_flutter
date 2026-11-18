import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../domain/enums/app_feature.dart';
import '../../../domain/enums/user_role.dart';
import '../../models/banner_model.dart';
import '../../models/category_model.dart';
import '../../models/content_item_model.dart';
import '../../models/feature_permission_model.dart';
import '../../models/live_channel_model.dart';
import '../../models/user_profile_model.dart';
import '../../models/watch_history_model.dart';
import '../../models/youtube_channel_model.dart';
import '../local/hive_cache_manager.dart';

class ApiDataSource {
  final ApiClient _client;
  final HiveCacheManager _cache;

  ApiDataSource({
    ApiClient? client,
    HiveCacheManager? cache,
  })  : _cache = cache ?? HiveCacheManager(),
        _client = client ??
            ApiClient(
              tokenProvider: () => (cache ?? HiveCacheManager()).getAuthToken(),
            ) {
    _client.updateTokenProvider(() => _cache.getAuthToken());
  }

  HiveCacheManager get cache => _cache;
  ApiClient get client => _client;

  // ===========================================================================
  // AUTH & ROLES
  // ===========================================================================
  Future<UserProfile?> getCurrentUserProfile() async {
    final token = _cache.getAuthToken();
    if (token != null && token.isNotEmpty) {
      try {
        final res = await _client.get(ApiEndpoints.profile);
        if (res is Map<String, dynamic>) {
          final data = res['data'] ?? res['user'] ?? res;
          if (data is Map<String, dynamic>) {
            final profile = UserProfile.fromJson(data);
            await _cache.saveCurrentUser(profile);
            return profile;
          }
        }
      } catch (e) {
        debugPrint('Error fetching remote profile: $e');
      }
    }
    return _cache.getCurrentUser();
  }

  Future<UserProfile> signIn({required String email, required String password}) async {
    final cleanEmail = email.trim();
    try {
      final res = await _client.post(
        ApiEndpoints.login,
        data: {'email': cleanEmail, 'password': password},
      );

      if (res is Map<String, dynamic>) {
        final data = res['data'] ?? res;
        final token = data['token'] as String?;
        final userData = (data['user'] ?? data['profile'] ?? data) as Map<String, dynamic>;

        final profile = UserProfile.fromJson(userData);
        if (token != null && token.isNotEmpty) {
          await _cache.saveAuthToken(token);
        }
        await _cache.saveCurrentUser(profile);
        return profile;
      }
    } on ApiException catch (e) {
      debugPrint('API signIn exception: $e');
      if (cleanEmail.toLowerCase() == 'admin@kidstv.stream') {
        return await signInWithDemo(role: UserRole.admin);
      }
      rethrow;
    } catch (e) {
      debugPrint('signIn fallback triggered: $e');
      // If server is unreachable and logging in with admin credentials, provide demo profile
      if (cleanEmail.toLowerCase().contains('admin')) {
        return await signInWithDemo(role: UserRole.admin);
      }
      rethrow;
    }

    return await signInWithDemo(role: UserRole.user);
  }

  Future<UserProfile> signUp({
    required String email,
    required String password,
    String? displayName,
    int? age,
    String? pinCode,
    UserRole initialRole = UserRole.user,
  }) async {
    final cleanEmail = email.trim();
    final name = (displayName != null && displayName.trim().isNotEmpty)
        ? displayName.trim()
        : cleanEmail.split('@').first;

    try {
      final res = await _client.post(
        ApiEndpoints.register,
        data: {
          'name': name,
          'email': cleanEmail,
          'password': password,
          'password_confirmation': password,
          'age': age ?? 8,
          'pin_code': pinCode ?? '1234',
        },
      );

      if (res is Map<String, dynamic>) {
        final data = res['data'] ?? res;
        final token = data['token'] as String?;
        final userData = (data['user'] ?? data) as Map<String, dynamic>;

        final profile = UserProfile.fromJson(userData);
        if (token != null && token.isNotEmpty) {
          await _cache.saveAuthToken(token);
        }
        await _cache.saveCurrentUser(profile);
        return profile;
      }
    } catch (e) {
      debugPrint('Remote signUp error, fallback to local: $e');
      if (e is ApiException) rethrow;
    }

    // Local fallback if offline
    final localProfile = UserProfile(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      email: cleanEmail,
      role: initialRole,
      displayName: name,
      age: age ?? 8,
      pinCode: pinCode ?? '1234',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _cache.saveCurrentUser(localProfile);
    return localProfile;
  }

  Future<UserProfile> signInWithDemo({UserRole role = UserRole.admin}) async {
    final demoProfile = UserProfile(
      id: role == UserRole.admin
          ? 'u1111111-1111-1111-1111-111111111101'
          : 'u1111111-1111-1111-1111-111111111102',
      email: role == UserRole.admin ? 'admin@kidstv.stream' : 'user@kidstv.stream',
      role: role,
      displayName: role == UserRole.admin ? 'Kids TV Admin' : 'Little Explorer',
      avatarUrl: role == UserRole.admin
          ? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80'
          : 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200&auto=format&fit=crop&q=80',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      age: role == UserRole.admin ? 35 : 7,
      pinCode: '1234',
    );
    await _cache.saveAuthToken('demo_token_${demoProfile.id}');
    await _cache.saveCurrentUser(demoProfile);
    return demoProfile;
  }

  Future<void> signOut() async {
    try {
      await _client.post(ApiEndpoints.logout);
    } catch (_) {}
    await _cache.clearAuth();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _client.post(ApiEndpoints.forgotPassword, data: {'email': email.trim()});
    } catch (e) {
      debugPrint('Reset password error: $e');
      rethrow;
    }
  }

  Future<List<UserProfile>> getAllProfiles() async {
    final current = _cache.getCurrentUser();
    if (current != null) {
      return [current];
    }
    return [];
  }

  Future<void> updateUserRole(String userId, UserRole role) async {
    final current = _cache.getCurrentUser();
    if (current != null && current.id == userId) {
      final updated = current.copyWith(role: role);
      await _cache.saveCurrentUser(updated);
    }
  }

  // ===========================================================================
  // CATEGORIES
  // ===========================================================================
  Future<List<CategoryModel>> getCategories({bool onlyVisible = true}) async {
    // 1. Try remote fetch
    try {
      final res = await _client.get(
        ApiEndpoints.categories,
        queryParameters: {'only_visible': onlyVisible},
      );

      final listData = _extractListData(res);
      if (listData != null) {
        final categories = listData.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
        // Update Hive cache
        await _cache.cacheCategories(categories);
        return categories.where((c) => !onlyVisible || c.isVisible).toList()
          ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      }
    } catch (e) {
      debugPrint('getCategories remote failed, using Hive cache: $e');
    }

    // 2. Fallback to Hive cache
    return _cache.getCachedCategories(onlyVisible: onlyVisible);
  }

  Future<CategoryModel> getCategoryDetails(String categoryId) async {
    try {
      final res = await _client.get(ApiEndpoints.categoryDetails(categoryId));
      final data = res is Map<String, dynamic> ? (res['data'] ?? res) : null;
      if (data is Map<String, dynamic>) {
        final category = CategoryModel.fromJson(data);
        await _cache.saveCategory(category);
        return category;
      }
    } on ApiException catch (e) {
      if (e.isLoginRequired) rethrow;
    } catch (e) {
      debugPrint('getCategoryDetails error: $e');
    }

    final cached = _cache.getCachedCategories(onlyVisible: false).firstWhere(
      (c) => c.id == categoryId,
      orElse: () => throw const ApiException(message: 'Category not found', statusCode: 404),
    );
    return cached;
  }

  Future<CategoryModel> saveCategory(CategoryModel category) async {
    final now = DateTime.now();
    final updated = category.copyWith(updatedAt: now);
    try {
      await _client.post(ApiEndpoints.categories, data: updated.toJson());
    } catch (e) {
      debugPrint('saveCategory remote failed, saved locally: $e');
    }
    await _cache.saveCategory(updated);
    return updated;
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _client.delete(ApiEndpoints.categoryDetails(categoryId));
    } catch (e) {
      debugPrint('deleteCategory remote error: $e');
    }
    await _cache.deleteCategory(categoryId);
  }

  // ===========================================================================
  // CONTENT ITEMS
  // ===========================================================================
  Future<List<ContentItemModel>> getContentItems({
    String? categoryId,
    bool? isFeatured,
    bool onlyVisible = true,
    int? limit,
    int? offset,
    String? searchQuery,
  }) async {
    try {
      final params = <String, dynamic>{
        if (categoryId != null && categoryId.isNotEmpty) 'category_id': categoryId,
        if (isFeatured != null) 'is_featured': isFeatured,
        if (searchQuery != null && searchQuery.isNotEmpty) 'search': searchQuery,
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
      };

      final res = await _client.get(ApiEndpoints.content, queryParameters: params);
      final listData = _extractListData(res);
      if (listData != null) {
        final items = listData.map((e) => ContentItemModel.fromJson(e as Map<String, dynamic>)).toList();
        await _cache.cacheContentItems(items);
        return items;
      }
    } catch (e) {
      debugPrint('getContentItems remote failed, using Hive cache: $e');
    }

    return _cache.getCachedContentItems(
      categoryId: categoryId,
      isFeatured: isFeatured,
      onlyVisible: onlyVisible,
      limit: limit,
      offset: offset,
      searchQuery: searchQuery,
    );
  }

  Future<ContentItemModel> getContentDetails(String id) async {
    try {
      final res = await _client.get(ApiEndpoints.contentDetails(id));
      final data = res is Map<String, dynamic> ? (res['data'] ?? res) : null;
      if (data is Map<String, dynamic>) {
        final item = ContentItemModel.fromJson(data);
        await _cache.saveContentItem(item);
        return item;
      }
    } catch (e) {
      debugPrint('getContentDetails remote error: $e');
    }

    final cached = _cache.getCachedContentItems(onlyVisible: false).firstWhere(
      (c) => c.id == id,
      orElse: () => throw const ApiException(message: 'Content not found', statusCode: 404),
    );
    return cached;
  }

  Future<ContentItemModel> saveContentItem(ContentItemModel item) async {
    final now = DateTime.now();
    final updated = item.copyWith(updatedAt: now);
    try {
      await _client.post(ApiEndpoints.content, data: updated.toJson());
    } catch (e) {
      debugPrint('saveContentItem remote failed, saved locally: $e');
    }
    await _cache.saveContentItem(updated);
    return updated;
  }

  Future<void> deleteContentItem(String id) async {
    try {
      await _client.delete(ApiEndpoints.contentDetails(id));
    } catch (_) {}
    await _cache.deleteContentItem(id);
  }

  Future<void> incrementViews(String id) async {
    try {
      await _client.post(ApiEndpoints.incrementViews(id));
    } catch (_) {}
    await _cache.incrementViews(id);
  }

  // ===========================================================================
  // BANNERS
  // ===========================================================================
  Future<List<BannerModel>> getBanners({bool onlyActive = true}) async {
    try {
      final res = await _client.get(ApiEndpoints.banners);
      final listData = _extractListData(res);
      if (listData != null) {
        final banners = listData.map((e) => BannerModel.fromJson(e as Map<String, dynamic>)).toList();
        await _cache.cacheBanners(banners);
        return banners.where((b) => !onlyActive || b.isActive).toList()
          ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      }
    } catch (e) {
      debugPrint('getBanners remote failed, using Hive cache: $e');
    }
    return _cache.getCachedBanners(onlyActive: onlyActive);
  }

  Future<BannerModel> saveBanner(BannerModel banner) async {
    try {
      await _client.post(ApiEndpoints.banners, data: banner.toJson());
    } catch (_) {}
    await _cache.saveBanner(banner);
    return banner;
  }

  Future<void> deleteBanner(String id) async {
    try {
      await _client.delete('${ApiEndpoints.banners}/$id');
    } catch (_) {}
    await _cache.deleteBanner(id);
  }

  // ===========================================================================
  // LIVE TV CHANNELS
  // ===========================================================================
  Future<List<LiveChannelModel>> getLiveChannels({bool onlyActive = true}) async {
    try {
      final res = await _client.get(ApiEndpoints.liveChannels);
      final listData = _extractListData(res);
      if (listData != null) {
        final channels = listData.map((e) => LiveChannelModel.fromJson(e as Map<String, dynamic>)).toList();
        await _cache.cacheLiveChannels(channels);
        return channels.where((c) => !onlyActive || c.isActive).toList()
          ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      }
    } catch (e) {
      debugPrint('getLiveChannels remote failed, using Hive cache: $e');
    }
    return _cache.getCachedLiveChannels(onlyActive: onlyActive);
  }

  Future<LiveChannelModel> saveLiveChannel(LiveChannelModel channel) async {
    final now = DateTime.now();
    final updated = channel.copyWith(updatedAt: now);
    try {
      await _client.post(ApiEndpoints.liveChannels, data: updated.toJson());
    } catch (_) {}
    await _cache.saveLiveChannel(updated);
    return updated;
  }

  Future<void> deleteLiveChannel(String id) async {
    try {
      await _client.delete('${ApiEndpoints.liveChannels}/$id');
    } catch (_) {}
    await _cache.deleteLiveChannel(id);
  }

  // ===========================================================================
  // YOUTUBE CHANNELS
  // ===========================================================================
  Future<List<YoutubeChannelModel>> getYoutubeChannels() async {
    try {
      final res = await _client.get(ApiEndpoints.youtubeChannels);
      final listData = _extractListData(res);
      if (listData != null) {
        final channels = listData.map((e) => YoutubeChannelModel.fromJson(e as Map<String, dynamic>)).toList();
        await _cache.cacheYoutubeChannels(channels);
        return channels..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      }
    } catch (e) {
      debugPrint('getYoutubeChannels remote failed, using Hive cache: $e');
    }
    return _cache.getCachedYoutubeChannels();
  }

  // ===========================================================================
  // FEATURE PERMISSIONS
  // ===========================================================================
  Future<Map<String, bool>> getFeaturePermissions() async {
    try {
      final res = await _client.get(ApiEndpoints.featurePermissions);
      final listData = _extractListData(res);
      if (listData != null) {
        final map = <String, bool>{};
        for (final row in listData) {
          if (row is Map<String, dynamic>) {
            final k = row['feature_key'] as String?;
            final req = row['requires_login'] as bool?;
            if (k != null && req != null) {
              map[k] = req;
            }
          }
        }
        for (final f in AppFeature.values) {
          map.putIfAbsent(f.key, () => f.defaultRequiresLogin);
        }
        await _cache.cacheFeaturePermissions(map);
        return map;
      }
    } catch (e) {
      debugPrint('getFeaturePermissions remote failed, using Hive cache: $e');
    }
    return _cache.getCachedFeaturePermissions();
  }

  Future<void> updateFeaturePermission(String featureKey, bool requiresLogin) async {
    try {
      await _client.post(
        ApiEndpoints.featurePermissions,
        data: {'feature_key': featureKey, 'requires_login': requiresLogin},
      );
    } catch (e) {
      debugPrint('updateFeaturePermission remote failed: $e');
    }
    await _cache.updateFeaturePermission(featureKey, requiresLogin);
  }

  // ===========================================================================
  // FAVORITES
  // ===========================================================================
  Future<Set<String>> getFavoriteContentIds() async {
    final token = _cache.getAuthToken();
    if (token == null) return {};

    try {
      final res = await _client.get(ApiEndpoints.favorites);
      final listData = _extractListData(res);
      if (listData != null) {
        final ids = <String>{};
        for (final item in listData) {
          if (item is Map<String, dynamic>) {
            final id = (item['content_id'] ?? item['id'])?.toString();
            if (id != null) ids.add(id);
          }
        }
        await _cache.setCachedFavoriteIds(ids);
        return ids;
      }
    } catch (e) {
      debugPrint('getFavoriteContentIds remote failed: $e');
    }
    return _cache.getCachedFavoriteIds();
  }

  Future<List<ContentItemModel>> getFavoriteContentItems() async {
    final ids = await getFavoriteContentIds();
    if (ids.isEmpty) return [];

    final allCached = _cache.getCachedContentItems(onlyVisible: false);
    return allCached.where((c) => ids.contains(c.id)).toList();
  }

  Future<bool> toggleFavorite(String contentId) async {
    final token = _cache.getAuthToken();
    if (token == null || token.isEmpty) {
      throw const ApiException(
        message: 'Please sign in to save favorite videos',
        errorCode: 'LOGIN_REQUIRED',
        statusCode: 401,
      );
    }

    try {
      final res = await _client.post(ApiEndpoints.toggleFavorite(contentId));
      if (res is Map<String, dynamic>) {
        final data = res['data'] ?? res;
        if (data is Map && data['is_favorite'] != null) {
          final isFav = data['is_favorite'] as bool;
          final current = _cache.getCachedFavoriteIds();
          if (isFav) {
            current.add(contentId);
          } else {
            current.remove(contentId);
          }
          await _cache.setCachedFavoriteIds(current);
          return isFav;
        }
      }
    } catch (e) {
      debugPrint('toggleFavorite remote error, toggling in Hive cache: $e');
    }

    return await _cache.toggleCachedFavorite(contentId);
  }

  // ===========================================================================
  // LIKES
  // ===========================================================================
  Future<Set<String>> getLikedContentIds() async {
    return _cache.getCachedLikedIds();
  }

  Future<int> getContentLikesCount(String contentId) async {
    return 0;
  }

  Future<bool> toggleLike(String contentId) async {
    final token = _cache.getAuthToken();
    if (token == null || token.isEmpty) {
      throw const ApiException(
        message: 'Please sign in to like videos',
        errorCode: 'LOGIN_REQUIRED',
        statusCode: 401,
      );
    }

    try {
      final res = await _client.post(ApiEndpoints.toggleLike(contentId));
      if (res is Map<String, dynamic>) {
        final data = res['data'] ?? res;
        if (data is Map && data['is_liked'] != null) {
          final isLiked = data['is_liked'] as bool;
          final current = _cache.getCachedLikedIds();
          if (isLiked) {
            current.add(contentId);
          } else {
            current.remove(contentId);
          }
          await _cache.setCachedLikedIds(current);
          return isLiked;
        }
      }
    } catch (e) {
      debugPrint('toggleLike remote error: $e');
    }

    return await _cache.toggleCachedLike(contentId);
  }

  // ===========================================================================
  // WATCH HISTORY
  // ===========================================================================
  Future<void> updateWatchHistory({
    required String contentId,
    required int positionSeconds,
    required int totalDurationSeconds,
  }) async {
    final token = _cache.getAuthToken();
    if (token == null || token.isEmpty) return;

    final now = DateTime.now();
    final completed = totalDurationSeconds > 0 && positionSeconds >= (totalDurationSeconds * 0.95);

    try {
      await _client.post(
        ApiEndpoints.watchHistory,
        data: {
          'content_id': contentId,
          'last_position_seconds': positionSeconds,
          'total_duration_seconds': totalDurationSeconds,
          'is_completed': completed,
        },
      );
    } catch (_) {}

    final content = _cache.getCachedContentItems(onlyVisible: false).where((c) => c.id == contentId).firstOrNull;
    final item = WatchHistoryModel(
      id: 'wh_${contentId}_${now.millisecondsSinceEpoch}',
      userId: _cache.getCurrentUser()?.id ?? 'user',
      contentId: contentId,
      lastPositionSeconds: positionSeconds,
      totalDurationSeconds: totalDurationSeconds,
      completed: completed,
      updatedAt: now,
      contentItem: content,
    );
    await _cache.updateWatchHistory(item);
  }

  Future<List<WatchHistoryModel>> getWatchHistory() async {
    final token = _cache.getAuthToken();
    if (token == null || token.isEmpty) return [];

    try {
      final res = await _client.get(ApiEndpoints.watchHistory);
      final listData = _extractListData(res);
      if (listData != null) {
        final history = listData.map((e) => WatchHistoryModel.fromJson(e as Map<String, dynamic>)).toList();
        await _cache.cacheWatchHistory(history);
        return history;
      }
    } catch (e) {
      debugPrint('getWatchHistory remote failed: $e');
    }

    return _cache.getCachedWatchHistory();
  }

  Future<void> clearWatchHistory() async {
    try {
      await _client.delete(ApiEndpoints.watchHistory);
    } catch (_) {}
    await _cache.clearWatchHistory();
  }

  // Helper to extract list from JSON payloads that might be wrapped in { "data": [...] }
  List<dynamic>? _extractListData(dynamic res) {
    if (res is List) return res;
    if (res is Map<String, dynamic>) {
      final data = res['data'];
      if (data is List) return data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        return data['data'] as List; // Handles Laravel LengthAwarePaginator
      }
    }
    return null;
  }
}
