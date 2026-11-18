import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/content_item_model.dart';
import '../../data/repositories/content_repository.dart';
import 'auth_provider.dart';

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  final ds = ref.watch(apiDataSourceProvider);
  return ContentRepository(ds);
});

class ContentState {
  final List<ContentItemModel> items;
  final bool isLoading;
  final String? error;
  final String? selectedCategoryId;
  final String searchQuery;

  const ContentState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategoryId,
    this.searchQuery = '',
  });

  List<ContentItemModel> get visibleItems =>
      items.where((i) => i.isVisible).toList()
        ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

  List<ContentItemModel> get featuredItems =>
      visibleItems.where((i) => i.isFeatured).toList();

  List<ContentItemModel> get popularItems {
    final list = List<ContentItemModel>.from(visibleItems);
    list.sort((a, b) => b.viewsCount.compareTo(a.viewsCount));
    return list;
  }

  List<ContentItemModel> get recentlyAddedItems {
    final list = List<ContentItemModel>.from(visibleItems);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  List<ContentItemModel> get filteredItems {
    var result = visibleItems;
    if (selectedCategoryId != null && selectedCategoryId!.isNotEmpty) {
      result = result.where((i) => i.categoryId == selectedCategoryId).toList();
    }
    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase().trim();
      result = result.where((i) {
        final matchesTitle = i.title.toLowerCase().contains(q);
        final matchesDesc = i.description?.toLowerCase().contains(q) ?? false;
        final matchesTag = i.tags.any((t) => t.toLowerCase().contains(q));
        return matchesTitle || matchesDesc || matchesTag;
      }).toList();
    }
    return result;
  }

  List<ContentItemModel> itemsForCategory(String categoryId) {
    return visibleItems.where((i) => i.categoryId == categoryId).toList();
  }

  List<ContentItemModel> get rhymesItems {
    final list = visibleItems
        .where((i) => i.categoryId == 'c1111111-1111-1111-1111-111111111101' || i.tags.contains('rhymes'))
        .toList();
    return list.isNotEmpty ? list : visibleItems.take(4).toList();
  }

  List<ContentItemModel> get cartoonItems {
    final list = visibleItems
        .where((i) => i.categoryId == 'c1111111-1111-1111-1111-111111111103' || i.tags.contains('cartoon'))
        .toList();
    return list.isNotEmpty ? list : visibleItems.skip(2).take(4).toList();
  }

  ContentState copyWith({
    List<ContentItemModel>? items,
    bool? isLoading,
    String? error,
    String? selectedCategoryId,
    bool clearCategory = false,
    String? searchQuery,
  }) {
    return ContentState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedCategoryId:
          clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ContentNotifier extends StateNotifier<ContentState> {
  final ContentRepository _repo;

  ContentNotifier(this._repo) : super(const ContentState()) {
    loadContent();
  }

  Future<void> loadContent({bool adminMode = false}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await _repo.getContentItems(onlyVisible: !adminMode);
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectCategory(String? categoryId) {
    if (categoryId == null) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategoryId: categoryId);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> saveContentItem(ContentItemModel item) async {
    state = state.copyWith(isLoading: true);
    try {
      final saved = await _repo.saveContentItem(item);
      final list = List<ContentItemModel>.from(state.items);
      final index = list.indexWhere((c) => c.id == saved.id);
      if (index != -1) {
        list[index] = saved;
      } else {
        list.add(saved);
      }
      list.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      state = state.copyWith(items: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteContentItem(String id) async {
    try {
      await _repo.deleteContentItem(id);
      final list = state.items.where((i) => i.id != id).toList();
      state = state.copyWith(items: list);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> toggleVisibility(String id) async {
    final item = state.items.firstWhere((i) => i.id == id);
    final updated = item.copyWith(isVisible: !item.isVisible);
    await saveContentItem(updated);
  }

  Future<void> toggleFeatured(String id) async {
    final item = state.items.firstWhere((i) => i.id == id);
    final updated = item.copyWith(isFeatured: !item.isFeatured);
    await saveContentItem(updated);
  }

  Future<void> incrementViews(String id) async {
    await _repo.incrementViews(id);
    final list = List<ContentItemModel>.from(state.items);
    final index = list.indexWhere((i) => i.id == id);
    if (index != -1) {
      final current = list[index];
      list[index] = current.copyWith(viewsCount: current.viewsCount + 1);
      state = state.copyWith(items: list);
    }
  }
}

final contentProvider =
    StateNotifierProvider<ContentNotifier, ContentState>((ref) {
  final repo = ref.watch(contentRepositoryProvider);
  return ContentNotifier(repo);
});
