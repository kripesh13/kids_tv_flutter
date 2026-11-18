enum AppType {
  admin,
  user;

  static AppType fromString(String? val) {
    if (val?.toLowerCase() == 'user') return AppType.user;
    return AppType.admin;
  }
}

class AppConfig {
  /// Compile-time or environment flag. Default is 'admin'.
  /// Pass --dart-define=APP_TYPE=user to run the User app.
  static const String _envAppType =
      String.fromEnvironment('APP_TYPE', defaultValue: 'admin');

  /// Primary centralized code configuration.
  /// Set to [AppType.admin] to run as Admin.
  /// Set to [AppType.user] to run as User.
  static const AppType appType =
      _envAppType == 'user' ? AppType.user : AppType.admin;

  static bool get isAdminApp => appType == AppType.admin;
  static bool get isUserApp => appType == AppType.user;
  static String get appRoleName => isAdminApp ? 'Admin' : 'User';
}
