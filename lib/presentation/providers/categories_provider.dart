import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/category_repository.dart';
import 'auth_provider.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final ds = ref.watch(apiDataSourceProvider);
  return CategoryRepository(ds);
});

class CategoriesState {
  final List<CategoryModel> categories;
  final bool isLoading;
  final String? error;

  const CategoriesState({
    this.categories = const [],
    this.isLoading = false,
    this.error,
  });

  List<CategoryModel> get visibleCategories =>
      categories.where((c) => c.isVisible).toList()
        ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

  List<CategoryModel> get featuredCategories =>
      visibleCategories.where((c) => c.isFeatured).toList();

  CategoriesState copyWith({
    List<CategoryModel>? categories,
    bool? isLoading,
    String? error,
  }) {
    return CategoriesState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CategoriesNotifier extends StateNotifier<CategoriesState> {
  final CategoryRepository _repo;

  CategoriesNotifier(this._repo) : super(const CategoriesState()) {
    loadCategories();
  }

  Future<void> loadCategories({bool adminMode = false}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repo.getCategories(onlyVisible: !adminMode);
      state = state.copyWith(categories: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> saveCategory(CategoryModel category) async {
    state = state.copyWith(isLoading: true);
    try {
      final saved = await _repo.saveCategory(category);
      final list = List<CategoryModel>.from(state.categories);
      final index = list.indexWhere((c) => c.id == saved.id);
      if (index != -1) {
        list[index] = saved;
      } else {
        list.add(saved);
      }
      list.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      state = state.copyWith(categories: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _repo.deleteCategory(id);
      final list = state.categories.where((c) => c.id != id).toList();
      state = state.copyWith(categories: list);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> toggleVisibility(String id) async {
    final cat = state.categories.firstWhere((c) => c.id == id);
    final updated = cat.copyWith(isVisible: !cat.isVisible);
    await saveCategory(updated);
  }

  Future<void> toggleFeatured(String id) async {
    final cat = state.categories.firstWhere((c) => c.id == id);
    final updated = cat.copyWith(isFeatured: !cat.isFeatured);
    await saveCategory(updated);
  }

  Future<void> reorderCategories(int oldIndex, int newIndex) async {
    final list = List<CategoryModel>.from(state.categories);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    // Update display orders
    for (int i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(displayOrder: i + 1);
      _repo.saveCategory(list[i]);
    }
    state = state.copyWith(categories: list);
  }
}

final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, CategoriesState>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return CategoriesNotifier(repo);
});
