import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/tv/tv_detector.dart';

class PlatformModeNotifier extends StateNotifier<bool?> {
  PlatformModeNotifier() : super(null);

  bool isTv(BuildContext context) {
    if (state != null) return state!;
    return TvDetector.isTvMode(context);
  }

  void toggleMode(BuildContext context) {
    final current = isTv(context);
    state = !current;
    TvDetector.setManualTvMode(!current);
  }

  void setMode(bool isTv) {
    state = isTv;
    TvDetector.setManualTvMode(isTv);
  }

  void resetToAuto() {
    state = null;
    TvDetector.clearManualMode();
  }
}

final platformModeProvider =
    StateNotifierProvider<PlatformModeNotifier, bool?>((ref) {
  return PlatformModeNotifier();
});
