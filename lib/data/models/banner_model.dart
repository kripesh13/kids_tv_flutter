import 'package:hive/hive.dart';
import '../../domain/enums/banner_action.dart';

part 'banner_model.g.dart';

@HiveType(typeId: 3)
class BannerModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? subtitle;

  @HiveField(3)
  final String imageUrl;

  @HiveField(4)
  final BannerAction actionType;

  @HiveField(5)
  final String actionTarget;

  @HiveField(6)
  final int displayOrder;

  @HiveField(7)
  final bool isActive;

  @HiveField(8)
  final DateTime createdAt;

  const BannerModel({
    required this.id,
    required this.title,
    this.subtitle,
    required this.imageUrl,
    this.actionType = BannerAction.content,
    required this.actionTarget,
    this.displayOrder = 0,
    this.isActive = true,
    required this.createdAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      imageUrl: json['image_url'] as String? ?? '',
      actionType: BannerAction.fromString(json['action_type'] as String?),
      actionTarget: json['action_target'] as String? ?? '',
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'image_url': imageUrl,
      'action_type': actionType.value,
      'action_target': actionTarget,
      'display_order': displayOrder,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  BannerModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? imageUrl,
    BannerAction? actionType,
    String? actionTarget,
    int? displayOrder,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return BannerModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      actionType: actionType ?? this.actionType,
      actionTarget: actionTarget ?? this.actionTarget,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
