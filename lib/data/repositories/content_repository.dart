import '../datasources/remote/api_data_source.dart';
import '../models/content_item_model.dart';

class ContentRepository {
  final ApiDataSource _dataSource;
  ContentRepository(this._dataSource);

  Future<List<ContentItemModel>> getContentItems({
    String? categoryId,
    bool? isFeatured,
    bool onlyVisible = true,
    int? limit,
    int? offset,
    String? searchQuery,
  }) =>
      _dataSource.getContentItems(
        categoryId: categoryId,
        isFeatured: isFeatured,
        onlyVisible: onlyVisible,
        limit: limit,
        offset: offset,
        searchQuery: searchQuery,
      );

  Future<ContentItemModel> getContentDetails(String id) =>
      _dataSource.getContentDetails(id);

  Future<ContentItemModel> saveContentItem(ContentItemModel item) =>
      _dataSource.saveContentItem(item);

  Future<void> deleteContentItem(String id) => _dataSource.deleteContentItem(id);

  Future<void> incrementViews(String id) => _dataSource.incrementViews(id);
}
