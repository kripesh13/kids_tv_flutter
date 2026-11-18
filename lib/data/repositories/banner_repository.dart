import '../datasources/remote/api_data_source.dart';
import '../models/banner_model.dart';

class BannerRepository {
  final ApiDataSource _dataSource;
  BannerRepository(this._dataSource);

  Future<List<BannerModel>> getBanners({bool onlyActive = true}) =>
      _dataSource.getBanners(onlyActive: onlyActive);

  Future<BannerModel> saveBanner(BannerModel banner) =>
      _dataSource.saveBanner(banner);

  Future<void> deleteBanner(String id) => _dataSource.deleteBanner(id);
}
