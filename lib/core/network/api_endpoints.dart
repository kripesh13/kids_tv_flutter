class ApiEndpoints {
  // Default base URL for Kids TV Laravel backend
  static const String defaultBaseUrl = 'http://127.0.0.1:8000/api/v1';
  static const String androidEmulatorBaseUrl = 'http://10.0.2.2:8000/api/v1';

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String profile = '/auth/profile';
  static const String avatar = '/auth/profile/avatar';
  static const String forgotPassword = '/auth/forgot-password';
  static const String logout = '/auth/logout';

  // Public / Streaming endpoints
  static const String categories = '/categories';
  static String categoryDetails(String id) => '/categories/$id';

  static const String content = '/content';
  static String contentDetails(String id) => '/content/$id';
  static String incrementViews(String id) => '/content/$id/views';

  static const String banners = '/banners';
  static const String liveChannels = '/live-channels';
  static const String youtubeChannels = '/youtube-channels';
  static const String featurePermissions = '/features/permissions';

  // Member endpoints
  static const String favorites = '/user/favorites';
  static String toggleFavorite(String contentId) => '/user/favorites/$contentId';
  static String toggleLike(String contentId) => '/user/likes/$contentId';
  static const String watchHistory = '/user/watch-history';

  // Legal endpoints
  static const String legal = '/legal';
  static const String privacyPolicy = '/legal/privacy-policy';
  static const String terms = '/legal/terms-and-conditions';
  static const String childSafety = '/legal/child-safety';
}
