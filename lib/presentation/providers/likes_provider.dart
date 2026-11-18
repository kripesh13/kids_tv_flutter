import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

class LikesState {
  final Set<String> likedIds;
  final Map<String, int> counts;

  const LikesState({
    this.likedIds = const {},
    this.counts = const {},
  });

  bool isLiked(String contentId) => likedIds.contains(contentId);
  int getCount(String contentId) => counts[contentId] ?? 0;

  LikesState copyWith({
    Set<String>? likedIds,
    Map<String, int>? counts,
  }) {
    return LikesState(
      likedIds: likedIds ?? this.likedIds,
      counts: counts ?? this.counts,
    );
  }
}

class LikesNotifier extends StateNotifier<LikesState> {
  final Ref _ref;

  LikesNotifier(this._ref) : super(const LikesState()) {
    loadUserLikes();
  }

  Future<void> loadUserLikes() async {
    final authState = _ref.read(authProvider);
    if (!authState.isAuthenticated) {
      state = state.copyWith(likedIds: {});
      return;
    }

    try {
      final ds = _ref.read(apiDataSourceProvider);
      final ids = await ds.getLikedContentIds();
      state = state.copyWith(likedIds: ids);
    } catch (_) {}
  }

  Future<void> fetchLikesCount(String contentId) async {
    try {
      final ds = _ref.read(apiDataSourceProvider);
      final count = await ds.getContentLikesCount(contentId);
      state = state.copyWith(
        counts: {...state.counts, contentId: count},
      );
    } catch (_) {}
  }

  Future<bool> toggleLike(String contentId) async {
    final ds = _ref.read(apiDataSourceProvider);
    final currentlyLiked = state.isLiked(contentId);
    final currentCount = state.getCount(contentId);

    // Optimistic update
    final newSet = Set<String>.from(state.likedIds);
    final newCounts = Map<String, int>.from(state.counts);

    if (currentlyLiked) {
      newSet.remove(contentId);
      newCounts[contentId] = (currentCount > 0) ? currentCount - 1 : 0;
    } else {
      newSet.add(contentId);
      newCounts[contentId] = currentCount + 1;
    }

    state = state.copyWith(likedIds: newSet, counts: newCounts);

    try {
      final isLiked = await ds.toggleLike(contentId);
      return isLiked;
    } catch (e) {
      // Revert on failure
      loadUserLikes();
      fetchLikesCount(contentId);
      rethrow;
    }
  }
}

final likesProvider = StateNotifierProvider<LikesNotifier, LikesState>((ref) {
  ref.watch(authProvider.select((s) => s.user?.id));
  return LikesNotifier(ref);
});
