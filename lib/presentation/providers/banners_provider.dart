import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/banner_model.dart';
import '../../data/repositories/banner_repository.dart';
import 'auth_provider.dart';

final bannerRepositoryProvider = Provider<BannerRepository>((ref) {
  final ds = ref.watch(apiDataSourceProvider);
  return BannerRepository(ds);
});

class BannersNotifier extends StateNotifier<AsyncValue<List<BannerModel>>> {
  final BannerRepository _repo;

  BannersNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadBanners();
  }

  Future<void> loadBanners({bool adminMode = false}) async {
    state = const AsyncValue.loading();
    try {
      final banners = await _repo.getBanners(onlyActive: !adminMode);
      state = AsyncValue.data(banners);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveBanner(BannerModel banner) async {
    try {
      await _repo.saveBanner(banner);
      loadBanners();
    } catch (_) {}
  }

  Future<void> deleteBanner(String id) async {
    try {
      await _repo.deleteBanner(id);
      loadBanners();
    } catch (_) {}
  }
}

final bannersProvider =
    StateNotifierProvider<BannersNotifier, AsyncValue<List<BannerModel>>>((ref) {
  final repo = ref.watch(bannerRepositoryProvider);
  return BannersNotifier(repo);
});
