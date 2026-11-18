import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/content_item_model.dart';
import 'auth_provider.dart';

class FavoritesState {
  final Set<String> favoriteIds;
  final List<ContentItemModel> favoriteItems;
  final bool isLoading;

  const FavoritesState({
    this.favoriteIds = const {},
    this.favoriteItems = const [],
    this.isLoading = false,
  });

  bool isFavorite(String contentId) => favoriteIds.contains(contentId);

  FavoritesState copyWith({
    Set<String>? favoriteIds,
    List<ContentItemModel>? favoriteItems,
    bool? isLoading,
  }) {
    return FavoritesState(
      favoriteIds: favoriteIds ?? this.favoriteIds,
      favoriteItems: favoriteItems ?? this.favoriteItems,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final Ref _ref;

  FavoritesNotifier(this._ref) : super(const FavoritesState()) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final authState = _ref.read(authProvider);
    if (!authState.isAuthenticated) {
      state = const FavoritesState();
      return;
    }

    state = state.copyWith(isLoading: true);
    try {
      final ds = _ref.read(apiDataSourceProvider);
      final ids = await ds.getFavoriteContentIds();
      final items = await ds.getFavoriteContentItems();
      state = state.copyWith(favoriteIds: ids, favoriteItems: items, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> toggleFavorite(ContentItemModel item) async {
    final ds = _ref.read(apiDataSourceProvider);
    final currentlyFav = state.isFavorite(item.id);

    // Optimistic UI update
    final newSet = Set<String>.from(state.favoriteIds);
    final newItems = List<ContentItemModel>.from(state.favoriteItems);

    if (currentlyFav) {
      newSet.remove(item.id);
      newItems.removeWhere((i) => i.id == item.id);
    } else {
      newSet.add(item.id);
      newItems.add(item);
    }

    state = state.copyWith(favoriteIds: newSet, favoriteItems: newItems);

    try {
      final added = await ds.toggleFavorite(item.id);
      return added;
    } catch (e) {
      // Revert if error
      loadFavorites();
      rethrow;
    }
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  // Reload when auth user changes
  ref.watch(authProvider.select((s) => s.user?.id));
  return FavoritesNotifier(ref);
});
