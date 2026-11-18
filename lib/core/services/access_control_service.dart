import 'package:flutter/material.dart';
import '../../domain/enums/app_feature.dart';
import '../../presentation/shared/widgets/login_prompt_bottom_sheet.dart';

class AccessControlService {
  final bool isAuthenticated;
  final Map<String, bool> featureSettings;

  const AccessControlService({
    required this.isAuthenticated,
    required this.featureSettings,
  });

  /// Check if user can enter a category
  bool canAccessCategory({required bool requiresLogin}) {
    if (!requiresLogin) return true;
    return isAuthenticated;
  }

  /// Check if a specific feature can be used
  bool canUseFeature(AppFeature feature) {
    // If not configurable, enforce default requirement
    final requiresLogin = featureSettings[feature.key] ?? feature.defaultRequiresLogin;
    if (!requiresLogin) return true;
    return isAuthenticated;
  }

  /// Guard a category tap, displaying the bottom sheet prompt if restricted
  bool guardCategory(
    BuildContext context, {
    required String categoryName,
    required bool requiresLogin,
    VoidCallback? onAllowed,
  }) {
    if (canAccessCategory(requiresLogin: requiresLogin)) {
      onAllowed?.call();
      return true;
    }

    LoginPromptBottomSheet.show(
      context,
      title: 'Sign in to access $categoryName',
      description:
          'This category requires an account. Create a free account or sign in to explore and watch all videos.',
      onAuthenticated: onAllowed,
    );
    return false;
  }

  /// Guard any feature (Favorites, Likes, Watch History, etc.)
  bool guardFeature(
    BuildContext context, {
    required AppFeature feature,
    String? customTitle,
    String? customDescription,
    VoidCallback? onAllowed,
  }) {
    if (canUseFeature(feature)) {
      onAllowed?.call();
      return true;
    }

    LoginPromptBottomSheet.show(
      context,
      title: customTitle ?? 'Sign in for ${feature.label}',
      description: customDescription ??
          'Sign in or create a free account to ${feature.description.toLowerCase()}.',
      onAuthenticated: onAllowed,
    );
    return false;
  }
}
