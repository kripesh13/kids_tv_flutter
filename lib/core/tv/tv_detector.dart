import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TvDetector {
  static bool _manualOverride = false;
  static bool _manualTvMode = false;

  /// Determines if the current environment is Android TV or configured for TV mode
  static bool isTvMode(BuildContext context) {
    if (_manualOverride) return _manualTvMode;

    // Check screen aspect ratio and size
    final mediaQuery = MediaQuery.of(context);
    final isLandscapeWide = mediaQuery.size.width >= 960 &&
        mediaQuery.size.aspectRatio >= 1.6 &&
        mediaQuery.orientation == Orientation.landscape;

    // Check platform
    if (!kIsWeb) {
      try {
        if (Platform.isAndroid) {
          // On Android, if width >= 900 in landscape, Leanback mode is likely
          return isLandscapeWide;
        }
      } catch (_) {}
    }

    return isLandscapeWide;
  }

  static void setManualTvMode(bool enabled) {
    _manualOverride = true;
    _manualTvMode = enabled;
  }

  static void clearManualMode() {
    _manualOverride = false;
  }

  static bool get hasManualOverride => _manualOverride;
  static bool get currentManualValue => _manualTvMode;
}
