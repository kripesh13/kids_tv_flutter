import 'package:hive/hive.dart';
import '../../domain/enums/app_feature.dart';

part 'feature_permission_model.g.dart';

@HiveType(typeId: 7)
class FeaturePermissionModel {
  @HiveField(0)
  final String featureKey;

  @HiveField(1)
  final bool requiresLogin;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final DateTime updatedAt;

  const FeaturePermissionModel({
    required this.featureKey,
    required this.requiresLogin,
    this.description,
    required this.updatedAt,
  });

  AppFeature? get feature => AppFeature.fromKey(featureKey);

  factory FeaturePermissionModel.fromFeature(AppFeature feature, {bool? requiresLogin}) {
    return FeaturePermissionModel(
      featureKey: feature.key,
      requiresLogin: requiresLogin ?? feature.defaultRequiresLogin,
      description: feature.description,
      updatedAt: DateTime.now(),
    );
  }

  factory FeaturePermissionModel.fromJson(Map<String, dynamic> json) {
    return FeaturePermissionModel(
      featureKey: json['feature_key'] as String? ?? '',
      requiresLogin: json['requires_login'] as bool? ?? false,
      description: json['description'] as String?,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'feature_key': featureKey,
      'requires_login': requiresLogin,
      'description': description,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  FeaturePermissionModel copyWith({
    String? featureKey,
    bool? requiresLogin,
    String? description,
    DateTime? updatedAt,
  }) {
    return FeaturePermissionModel(
      featureKey: featureKey ?? this.featureKey,
      requiresLogin: requiresLogin ?? this.requiresLogin,
      description: description ?? this.description,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
