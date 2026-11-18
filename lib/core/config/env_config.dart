import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnvConfig {
  static const String _defaultUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api/v1',
  );

  static String _currentUrl = _defaultUrl;
  static bool _isLoaded = false;

  /// Returns the configured Base URL for the Kids TV backend API.
  /// Automatically resolves localhost to 10.0.2.2 on Android emulator when appropriate.
  static String get apiBaseUrl {
    if (!kIsWeb && Platform.isAndroid && _currentUrl.contains('127.0.0.1')) {
      return _currentUrl.replaceAll('127.0.0.1', '10.0.2.2');
    }
    return _currentUrl;
  }

  static bool get isConfigured => _currentUrl.isNotEmpty;
  static bool get isLoaded => _isLoaded;

  /// Loads saved configuration from SharedPreferences if available
  static Future<void> loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUrl = prefs.getString('api_base_url');

      if (savedUrl != null && savedUrl.trim().isNotEmpty) {
        _currentUrl = savedUrl.trim();
      }
      _isLoaded = true;
      debugPrint('Kids TV API Config loaded: $apiBaseUrl');
    } catch (e) {
      debugPrint('Error loading EnvConfig: $e');
    }
  }

  /// Updates and stores API Base URL dynamically (e.g. from Admin settings screen)
  static Future<bool> updateApiBaseUrl(String url) async {
    try {
      final cleanUrl = url.trim();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('api_base_url', cleanUrl);
      _currentUrl = cleanUrl;
      debugPrint('Updated API Base URL to: $cleanUrl');
      return true;
    } catch (e) {
      debugPrint('updateApiBaseUrl error: $e');
      return false;
    }
  }
}
