import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/enums/app_feature.dart';
import 'auth_provider.dart';

class FeaturePermissionsNotifier extends StateNotifier<Map<String, bool>> {
  final Ref _ref;

  FeaturePermissionsNotifier(this._ref) : super(_defaultMap()) {
    loadPermissions();
  }

  static Map<String, bool> _defaultMap() {
    final map = <String, bool>{};
    for (final f in AppFeature.values) {
      map[f.key] = f.defaultRequiresLogin;
    }
    return map;
  }

  Future<void> loadPermissions() async {
    try {
      final ds = _ref.read(apiDataSourceProvider);
      final perms = await ds.getFeaturePermissions();
      state = {...state, ...perms};
    } catch (_) {}
  }

  Future<void> setFeatureRequirement(String featureKey, bool requiresLogin) async {
    state = {...state, featureKey: requiresLogin};
    try {
      final ds = _ref.read(apiDataSourceProvider);
      await ds.updateFeaturePermission(featureKey, requiresLogin);
    } catch (_) {}
  }
}

final featurePermissionsProvider =
    StateNotifierProvider<FeaturePermissionsNotifier, Map<String, bool>>((ref) {
  return FeaturePermissionsNotifier(ref);
});
