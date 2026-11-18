import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/access_control_service.dart';
import 'auth_provider.dart';
import 'feature_permissions_provider.dart';

final accessControlProvider = Provider<AccessControlService>((ref) {
  final authState = ref.watch(authProvider);
  final featureSettings = ref.watch(featurePermissionsProvider);

  return AccessControlService(
    isAuthenticated: authState.isAuthenticated,
    featureSettings: featureSettings,
  );
});
