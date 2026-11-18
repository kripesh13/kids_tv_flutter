import 'package:flutter/material.dart';

enum AppFeature {
  browseVideos(
    key: 'browse_videos',
    label: 'Browse Videos',
    description: 'Allow guests to browse published video titles and categories',
    defaultRequiresLogin: false,
    isConfigurable: true,
  ),
  watchVideos(
    key: 'watch_videos',
    label: 'Watch Videos',
    description: 'Allow guests to stream and watch public videos without logging in',
    defaultRequiresLogin: false,
    isConfigurable: true,
  ),
  favorites(
    key: 'favorites',
    label: 'Add to Favorites',
    description: 'Save favorite videos to personal cloud account',
    defaultRequiresLogin: true,
    isConfigurable: false,
  ),
  likes(
    key: 'likes',
    label: 'Like Videos',
    description: 'Allow giving thumbs up / likes on videos',
    defaultRequiresLogin: true,
    isConfigurable: false,
  ),
  watchHistory(
    key: 'watch_history',
    label: 'Watch History',
    description: 'Track viewed videos in account history',
    defaultRequiresLogin: true,
    isConfigurable: false,
  ),
  continueWatching(
    key: 'continue_watching',
    label: 'Continue Watching',
    description: 'Resume playback where left off across devices',
    defaultRequiresLogin: true,
    isConfigurable: false,
  ),
  restrictedCategories(
    key: 'restricted_categories',
    label: 'Access Restricted Categories',
    description: 'Enter categories marked with Require User Login',
    defaultRequiresLogin: true,
    isConfigurable: false,
  ),
  search(
    key: 'search',
    label: 'Search Content',
    description: 'Search video titles, characters and tags',
    defaultRequiresLogin: false,
    isConfigurable: true,
  ),
  shareVideos(
    key: 'share_videos',
    label: 'Share Content',
    description: 'Share video links, categories and channels',
    defaultRequiresLogin: false,
    isConfigurable: true,
  );

  final String key;
  final String label;
  final String description;
  final bool defaultRequiresLogin;
  final bool isConfigurable;

  const AppFeature({
    required this.key,
    required this.label,
    required this.description,
    required this.defaultRequiresLogin,
    required this.isConfigurable,
  });

  IconData get icon {
    switch (this) {
      case AppFeature.browseVideos:
        return Icons.video_library_rounded;
      case AppFeature.watchVideos:
        return Icons.play_circle_rounded;
      case AppFeature.favorites:
        return Icons.favorite_rounded;
      case AppFeature.likes:
        return Icons.thumb_up_rounded;
      case AppFeature.watchHistory:
        return Icons.history_rounded;
      case AppFeature.continueWatching:
        return Icons.play_arrow_rounded;
      case AppFeature.restrictedCategories:
        return Icons.lock_rounded;
      case AppFeature.search:
        return Icons.search_rounded;
      case AppFeature.shareVideos:
        return Icons.share_rounded;
    }
  }

  static AppFeature? fromKey(String key) {
    for (final f in AppFeature.values) {
      if (f.key == key) return f;
    }
    return null;
  }
}
