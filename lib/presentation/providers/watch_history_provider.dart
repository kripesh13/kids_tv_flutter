import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/watch_history_model.dart';
import 'auth_provider.dart';

class WatchHistoryState {
  final List<WatchHistoryModel> items;
  final bool isLoading;

  const WatchHistoryState({
    this.items = const [],
    this.isLoading = false,
  });

  /// Items that were started but not completed (between 5% and 95% progress)
  List<WatchHistoryModel> get continueWatching =>
      items.where((h) => !h.completed && h.progressPercentage > 0.05).toList();

  WatchHistoryState copyWith({
    List<WatchHistoryModel>? items,
    bool? isLoading,
  }) {
    return WatchHistoryState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class WatchHistoryNotifier extends StateNotifier<WatchHistoryState> {
  final Ref _ref;

  WatchHistoryNotifier(this._ref) : super(const WatchHistoryState()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    final authState = _ref.read(authProvider);
    if (!authState.isAuthenticated) {
      state = const WatchHistoryState();
      return;
    }

    state = state.copyWith(isLoading: true);
    try {
      final ds = _ref.read(apiDataSourceProvider);
      final history = await ds.getWatchHistory();
      state = state.copyWith(items: history, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> updateProgress({
    required String contentId,
    required int positionSeconds,
    required int totalDurationSeconds,
  }) async {
    final authState = _ref.read(authProvider);
    if (!authState.isAuthenticated) return; // Guests do not save progress

    try {
      final ds = _ref.read(apiDataSourceProvider);
      await ds.updateWatchHistory(
        contentId: contentId,
        positionSeconds: positionSeconds,
        totalDurationSeconds: totalDurationSeconds,
      );
      // Reload history quietly
      final history = await ds.getWatchHistory();
      state = state.copyWith(items: history);
    } catch (_) {}
  }

  Future<void> clearHistory() async {
    try {
      final ds = _ref.read(apiDataSourceProvider);
      await ds.clearWatchHistory();
      state = const WatchHistoryState();
    } catch (_) {}
  }
}

final watchHistoryProvider =
    StateNotifierProvider<WatchHistoryNotifier, WatchHistoryState>((ref) {
  ref.watch(authProvider.select((s) => s.user?.id));
  return WatchHistoryNotifier(ref);
});
