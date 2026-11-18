import '../datasources/remote/api_data_source.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final ApiDataSource _dataSource;
  CategoryRepository(this._dataSource);

  Future<List<CategoryModel>> getCategories({bool onlyVisible = true}) =>
      _dataSource.getCategories(onlyVisible: onlyVisible);

  Future<CategoryModel> getCategoryDetails(String id) =>
      _dataSource.getCategoryDetails(id);

  Future<CategoryModel> saveCategory(CategoryModel category) =>
      _dataSource.saveCategory(category);

  Future<void> deleteCategory(String categoryId) =>
      _dataSource.deleteCategory(categoryId);
}
